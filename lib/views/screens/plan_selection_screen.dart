import 'package:flutter/material.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Native subscription plan selection screen.
///
/// Shows all plans from the backend (which syncs from Chargebee),
/// grouped by category (Delight/Signature/Premium) and size (200ml/300ml/500ml).
/// Each plan has Weekly and Monthly pricing options.
/// Selecting a plan opens the Chargebee hosted checkout WebView for payment only.
class PlanSelectionScreen extends StatefulWidget {
  static const routeName = '/plan-selection';

  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Map<String, dynamic>> _allPlans = [];
  bool _isLoading = true;
  String? _error;

  // Selection state
  String? _selectedCategory; // delight, signature, premium
  String? _selectedSize; // 200, 300, 500
  String? _selectedPeriod; // Weekly, Monthly
  Map<String, dynamic>? _selectedItemPrice;

  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plans = await _subscriptionService.getSubscriptionPlans();
      setState(() {
        _allPlans = plans;
        _isLoading = false;
        // Auto-select first category and size
        if (plans.isNotEmpty) {
          _selectedCategory = _extractCategory(plans.first);
          _selectedSize = _extractSize(plans.first);
          _selectedPeriod = 'Weekly';
          _updateSelectedItemPrice();
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _extractCategory(Map<String, dynamic> plan) {
    final name = (plan['name'] as String?) ?? '';
    final itemId = (plan['id'] as String?) ?? '';
    // Try to infer from item_family_id or item_id
    final familyId = (plan['itemFamilyId'] as String?) ?? '';
    if (familyId.isNotEmpty) return familyId;

    if (itemId.startsWith('delight') || name.toLowerCase().contains('delight')) {
      return 'delight';
    } else if (itemId.startsWith('signature') || name.toLowerCase().contains('signature')) {
      return 'signature';
    } else if (itemId.startsWith('premium') || name.toLowerCase().contains('premium')) {
      return 'premium';
    }
    return 'delight';
  }

  String _extractSize(Map<String, dynamic> plan) {
    final name = (plan['name'] as String?) ?? '';
    final itemId = (plan['id'] as String?) ?? '';
    // Try to find size in name or id
    for (final size in ['200', '300', '500']) {
      if (name.contains('${size}ml') || itemId.contains('-$size') || itemId.endsWith('-$size')) {
        return size;
      }
    }
    return '200';
  }

  String _extractPeriod(Map<String, dynamic> plan) {
    final name = (plan['name'] as String?) ?? '';
    if (name.toLowerCase().contains('weekly') || name.toLowerCase().contains('week')) {
      return 'Weekly';
    } else if (name.toLowerCase().contains('monthly') || name.toLowerCase().contains('month')) {
      return 'Monthly';
    }
    // Check period data
    final periodUnit = (plan['periodUnit'] as String?) ?? '';
    final period = (plan['period'] as int?) ?? 0;
    if (periodUnit == 'month' || period >= 24) {
      return 'Monthly';
    }
    return 'Weekly';
  }

  /// Get all unique categories from plans
  List<String> get _categories {
    final cats = <String>{};
    for (final plan in _allPlans) {
      cats.add(_extractCategory(plan));
    }
    return cats.toList()..sort();
  }

  /// Get all unique sizes from plans
  List<String> get _sizes {
    final sz = <String>{};
    for (final plan in _allPlans) {
      sz.add(_extractSize(plan));
    }
    return sz.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  /// Get plans matching selected category + size
  List<Map<String, dynamic>> get _filteredPlans {
    if (_selectedCategory == null || _selectedSize == null) return [];
    return _allPlans.where((p) =>
        _extractCategory(p) == _selectedCategory &&
        _extractSize(p) == _selectedSize,).toList();
  }

  /// Get the display name for a category
  String _categoryDisplay(String cat) {
    switch (cat) {
      case 'delight':
        return 'Delight';
      case 'signature':
        return 'Signature';
      case 'premium':
        return 'Premium';
      default:
        return cat;
    }
  }

  /// Get the color for a category
  Color _categoryColor(String cat) {
    switch (cat) {
      case 'delight':
        return AppColors.success;
      case 'signature':
        return AppColors.info;
      case 'premium':
        return AppColors.primaryOrange;
      default:
        return AppColors.secondaryTeal;
    }
  }

  /// Get the icon for a category
  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'delight':
        return Icons.eco;
      case 'signature':
        return Icons.auto_awesome;
      case 'premium':
        return Icons.star;
      default:
        return Icons.category;
    }
  }

  void _updateSelectedItemPrice() {
    final filtered = _filteredPlans;
    if (filtered.isEmpty) {
      setState(() => _selectedItemPrice = null);
      return;
    }

    // Find the plan with matching period
    Map<String, dynamic>? match;
    for (final plan in filtered) {
      if (_extractPeriod(plan) == _selectedPeriod) {
        match = plan;
        break;
      }
    }

    // Fallback to first plan
    setState(() {
      _selectedItemPrice = match ?? filtered.first;
    });
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    if (price is int) {
      return '₹${(price / 100).toStringAsFixed(0)}'; // Convert from paise to rupees
    }
    if (price is double) {
      return '₹${price.toStringAsFixed(0)}';
    }
    return '₹$price';
  }

  Future<void> _subscribeToPlan() async {
    if (_selectedItemPrice == null) return;
    final planId = _selectedItemPrice!['id'] as String?;
    if (planId == null || planId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid plan selected')),
      );
      return;
    }

    setState(() => _isSubscribing = true);

    try {
      final result = await _subscriptionService.createSubscription(planId);
      final url = result['url'] as String?;

      if (url != null && url.isNotEmpty && mounted) {
        // Open Chargebee hosted checkout in WebView
        Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => _ChargebeeCheckoutWebView(url: url),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get checkout URL: ${result['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubscribing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlans,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _allPlans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No subscription plans available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Plans will appear once configured in Chargebee.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlans,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step 1: Select Category
                            _buildSectionTitle('1. Choose Category'),
                            const SizedBox(height: 8),
                            _buildCategorySelector(),
                            const SizedBox(height: 24),

                            // Step 2: Select Size
                            _buildSectionTitle('2. Choose Size'),
                            const SizedBox(height: 8),
                            _buildSizeSelector(),
                            const SizedBox(height: 24),

                            // Step 3: Select Period
                            if (_filteredPlans.length > 1) ...[
                              _buildSectionTitle('3. Choose Plan Duration'),
                              const SizedBox(height: 8),
                              _buildPeriodSelector(),
                              const SizedBox(height: 24),
                            ],

                            // Plan Summary & Subscribe Button
                            if (_selectedItemPrice != null)
                              _buildPlanSummary(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        final color = _categoryColor(cat);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: cat == _categories.first ? 0 : 4,
              right: cat == _categories.last ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _updateSelectedItemPrice();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      _categoryIcon(cat),
                      color: isSelected ? color : Colors.grey[400],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _categoryDisplay(cat),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector() {
    return Row(
      children: _sizes.map((size) {
        final isSelected = _selectedSize == size;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: size == _sizes.first ? 0 : 4,
              right: size == _sizes.last ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                  _updateSelectedItemPrice();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '${size}ml',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = <String>{};
    for (final plan in _filteredPlans) {
      periods.add(_extractPeriod(plan));
    }

    return Row(
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        final isWeekly = period == 'Weekly';
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: period == periods.first ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _updateSelectedItemPrice();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isWeekly ? Colors.teal : Colors.deepPurple).withValues(alpha: 0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (isWeekly ? Colors.teal : Colors.deepPurple)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isWeekly ? Icons.calendar_view_week : Icons.calendar_month,
                      color: isSelected
                          ? (isWeekly ? Colors.teal : Colors.deepPurple)
                          : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? (isWeekly ? Colors.teal : Colors.deepPurple)
                            : Colors.grey[600],
                      ),
                    ),
                    if (_selectedItemPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(_selectedItemPrice!['price']),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.green[700] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSummary() {
    final plan = _selectedItemPrice!;
    final name = (plan['name'] as String?) ?? 'Plan';
    final priceStr = _formatPrice(plan['price']);
    final description = (plan['description'] as String?) ?? '';
    final period = _selectedPeriod ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _categoryColor(_selectedCategory ?? '').withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(_selectedCategory ?? ''),
                        size: 16,
                        color: _categoryColor(_selectedCategory ?? ''),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _categoryDisplay(_selectedCategory ?? ''),
                        style: TextStyle(
                          color: _categoryColor(_selectedCategory ?? ''),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedSize}ml',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$period Plan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        priceStr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubscribing ? null : _subscribeToPlan,
                icon: _isSubscribing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock),
                label: Text(
                  _isSubscribing ? 'Processing...' : 'Subscribe Now',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '💳 You will be redirected to secure payment page',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chargebee hosted checkout WebView - only for payment completion
class _ChargebeeCheckoutWebView extends StatefulWidget {
  final String url;

  const _ChargebeeCheckoutWebView({required this.url});

  @override
  State<_ChargebeeCheckoutWebView> createState() => _ChargebeeCheckoutWebViewState();
}

class _ChargebeeCheckoutWebViewState extends State<_ChargebeeCheckoutWebView> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingProgress = 100;
            });
            // Check if we've returned from successful payment
            if (url.contains('chargebee.com') && url.contains('checkout')) {
              // User completed or cancelled - let them navigate back
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        actions: [
          if (_loadingProgress < 100)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
