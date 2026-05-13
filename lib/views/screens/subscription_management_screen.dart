import 'package:flutter/material.dart';
import 'package:lush/services/local_notification_service.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// BR-041 to BR-046: Subscription management with 9 PM IST cutoff,
/// confirmation dialogs, state refetch, and local notifications.
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
  final LocalNotificationService _notifications = LocalNotificationService();
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

  /// BR-041/BR-042: Check if current time is before 9 PM IST.
  bool _isBefore9PMIST() {
    // All users and servers are in IST (Asia/Kolkata) timezone.
    final now = DateTime.now();
    // Convert to IST if device is in a different timezone
    final istOffset = Duration(hours: 5, minutes: 30);
    final utcNow = now.toUtc();
    final istNow = utcNow.add(istOffset);
    return istNow.hour < 21; // Before 9 PM
  }

  /// BR-041: Pause subscription with 9 PM IST cutoff and confirmation dialog.
  Future<void> _pauseSubscription(String subscriptionId, String planName) async {
    // Check 9 PM IST cutoff
    if (!_isBefore9PMIST()) {
      _showDialog(
        title: 'Action Unavailable',
        content: 'Subscription actions are available until 9 PM IST only. Changes will take effect next day.',
        confirmText: 'OK',
        isWarning: true,
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await _showDialog(
      title: 'Pause Subscription',
      content: 'Pause delivery starting tomorrow? You can resume anytime before 9 PM IST.',
      confirmText: 'Pause',
      cancelText: 'No',
    );

    if (confirmed != true) return;

    // Execute pause
    try {
      final result = await _subscriptionService.pauseSubscription(subscriptionId);

      // BR-046: Refetch confirmed state from bmjServer
      await _loadSubscriptions();

      // BR-061: Schedule local notification
      _notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Subscription Paused',
        body: 'Your $planName subscription has been paused.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Subscription paused')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  /// BR-042: Resume subscription with 9 PM IST cutoff and confirmation dialog.
  Future<void> _resumeSubscription(String subscriptionId, String planName) async {
    if (!_isBefore9PMIST()) {
      _showDialog(
        title: 'Action Unavailable',
        content: 'Subscription actions are available until 9 PM IST only. Changes will take effect next day.',
        confirmText: 'OK',
        isWarning: true,
      );
      return;
    }

    final confirmed = await _showDialog(
      title: 'Resume Subscription',
      content: 'Resume your $planName subscription starting immediately?',
      confirmText: 'Resume',
      cancelText: 'No',
    );

    if (confirmed != true) return;

    try {
      final result = await _subscriptionService.resumeSubscription(subscriptionId);

      // BR-046: Refetch confirmed state
      await _loadSubscriptions();

      // BR-061: Local notification
      _notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Subscription Resumed',
        body: 'Your $planName subscription is active again.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Subscription resumed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  /// BR-043: Cancel subscription with confirmation dialog and options.
  Future<void> _cancelSubscription(String subscriptionId, String planName) async {
    final confirmed = await _showDialog(
      title: 'Cancel Subscription',
      content: 'Are you sure you want to cancel your $planName subscription? Access continues until the end of the current billing period.',
      confirmText: 'Yes, Cancel',
      cancelText: 'No',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final result = await _subscriptionService.cancelSubscription(subscriptionId);

      // BR-046: Refetch confirmed state
      await _loadSubscriptions();

      // BR-061: Local notification
      _notifications.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Subscription Cancelled',
        body: 'Your $planName subscription has been cancelled.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Subscription cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  /// Helper: Show confirmation dialog. Returns true if confirmed.
  Future<bool?> _showDialog({
    required String title,
    required String content,
    String confirmText = 'OK',
    String? cancelText,
    bool isWarning = false,
    bool isDestructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _browseSubscriptionPlans() async {
    try {
      final pricingUrl = await _subscriptionService.getPricingPageUrl();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ChargebeeWebView(url: pricingUrl),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pricing page: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.confirmExit(
          context,
          message: 'Operations may be in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
    ),);
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final status =
        subscription['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final planId = subscription['planId'] ?? 'Unknown Plan';
    final subscriptionId = subscription['id']?.toString() ?? '';

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

    final isBefore9PM = _isBefore9PMIST();

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
                    color: statusColor.withValues(alpha: 0.1),
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
            if (!isBefore9PM && (status == 'ACTIVE' || status == 'PAUSED'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⏰ Actions available after 9 AM tomorrow',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (status == 'ACTIVE')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: isBefore9PM
                        ? () => _pauseSubscription(subscriptionId, planId.toString())
                        : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelSubscription(subscriptionId, planId.toString()),
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
                    onPressed: isBefore9PM
                        ? () => _resumeSubscription(subscriptionId, planId.toString())
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelSubscription(subscriptionId, planId.toString()),
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
