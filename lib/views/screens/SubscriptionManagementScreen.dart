import 'package:flutter/material.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  static const routeName = '/subscription-management';

  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Map<String, dynamic>> _subscriptions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subscriptions = await _subscriptionService.getMySubscriptions();
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pauseSubscription(String subscriptionId) async {
    try {
      final success =
          await _subscriptionService.pauseSubscription(subscriptionId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription paused successfully')),
        );
        _loadSubscriptions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pause subscription: $e')),
      );
    }
  }

  Future<void> _resumeSubscription(String subscriptionId) async {
    try {
      final success =
          await _subscriptionService.resumeSubscription(subscriptionId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription resumed successfully')),
        );
        _loadSubscriptions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resume subscription: $e')),
      );
    }
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content:
            const Text('Are you sure you want to cancel this subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success =
            await _subscriptionService.cancelSubscription(subscriptionId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription canceled successfully')),
          );
          _loadSubscriptions();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel subscription: $e')),
        );
      }
    }
  }

  Future<void> _browseSubscriptionPlans() async {
    try {
      final pricingUrl = await _subscriptionService.getPricingPageUrl();

      // Open in webview
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ChargebeeWebView(url: pricingUrl),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pricing page: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSubscriptions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _subscriptions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.subscriptions_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No active subscriptions',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _browseSubscriptionPlans,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Browse Plans'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSubscriptions,
                      child: ListView.builder(
                        itemCount: _subscriptions.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final subscription = _subscriptions[index];
                          return _buildSubscriptionCard(subscription);
                        },
                      ),
                    ),
      floatingActionButton: _subscriptions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _browseSubscriptionPlans,
              icon: const Icon(Icons.add),
              label: const Text('Add Subscription'),
            )
          : null,
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final status =
        subscription['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final planId = subscription['planId'] ?? 'Unknown Plan';
    final subscriptionId = subscription['id'];

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'ACTIVE':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'PAUSED':
        statusColor = Colors.orange;
        statusIcon = Icons.pause_circle;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    planId.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('ID: $subscriptionId'),
            if (subscription['nextBillingAt'] != null)
              Text(
                  'Next Billing: ${DateTime.fromMillisecondsSinceEpoch((subscription['nextBillingAt'] as int) * 1000).toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            if (status == 'ACTIVE')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _pauseSubscription(subscriptionId.toString()),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelSubscription(subscriptionId.toString()),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              )
            else if (status == 'PAUSED')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _resumeSubscription(subscriptionId.toString()),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelSubscription(subscriptionId.toString()),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ChargebeeWebView extends StatefulWidget {
  final String url;

  const _ChargebeeWebView({required this.url});

  @override
  State<_ChargebeeWebView> createState() => _ChargebeeWebViewState();
}

class _ChargebeeWebViewState extends State<_ChargebeeWebView> {
  late WebViewController _controller;
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
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
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
