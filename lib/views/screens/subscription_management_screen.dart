import 'package:flutter/material.dart';
import 'package:lush/services/local_notification_service.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:lush/utils/subscription_view_utils.dart';
import 'package:lush/views/screens/plan_selection_screen.dart';
import 'package:lush/widgets/bmj_empty_state.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_glass_header.dart';
import 'package:lush/widgets/bmj_stat_tile.dart';

/// BR-041 to BR-046: Subscription management with 9 PM IST cutoff,
/// confirmation dialogs, state refetch, and local notifications.
class SubscriptionManagementScreen extends StatefulWidget {
  static const routeName = '/subscription-management';

  /// When true the screen renders inside the dashboard tab: no Scaffold app
  /// bar, no exit guard. The `/manage-subscriptions` route still pushes the
  /// full screen (default `false`).
  final bool embedded;

  const SubscriptionManagementScreen({super.key, this.embedded = false});

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
      if (!mounted) return; // DP-2: the route may be gone already
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // DP-2: never setState after dispose
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
    const istOffset = Duration(hours: 5, minutes: 30);
    final utcNow = now.toUtc();
    final istNow = utcNow.add(istOffset);
    return istNow.hour < 21; // Before 9 PM
  }

  /// BR-041: Pause subscription with 9 PM IST cutoff and confirmation dialog.
  Future<void> _pauseSubscription(
      String subscriptionId, String planName) async {
    // Check 9 PM IST cutoff
    if (!_isBefore9PMIST()) {
      _showDialog(
        title: 'Action Unavailable',
        content:
            'Subscription actions are available until 9 PM IST only. Changes will take effect next day.',
        isWarning: true,
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await _showDialog(
      title: 'Pause Subscription',
      content:
          'Pause delivery starting tomorrow? You can resume anytime before 9 PM IST.',
      confirmText: 'Pause',
      cancelText: 'No',
    );

    if (confirmed != true) return;

    // Execute pause
    try {
      final result =
          await _subscriptionService.pauseSubscription(subscriptionId);

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
          SnackBar(
              content:
                  Text(result['message'] as String? ?? 'Subscription paused')),
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
  Future<void> _resumeSubscription(
      String subscriptionId, String planName) async {
    if (!_isBefore9PMIST()) {
      _showDialog(
        title: 'Action Unavailable',
        content:
            'Subscription actions are available until 9 PM IST only. Changes will take effect next day.',
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
      final result =
          await _subscriptionService.resumeSubscription(subscriptionId);

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
          SnackBar(
              content:
                  Text(result['message'] as String? ?? 'Subscription resumed')),
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
  Future<void> _cancelSubscription(
      String subscriptionId, String planName) async {
    final confirmed = await _showDialog(
      title: 'Cancel Subscription',
      content:
          'Are you sure you want to cancel your $planName subscription? Access continues until the end of the current billing period.',
      confirmText: 'Yes, Cancel',
      cancelText: 'No',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final result =
          await _subscriptionService.cancelSubscription(subscriptionId);

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
          SnackBar(
              content: Text(
                  result['message'] as String? ?? 'Subscription cancelled')),
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
    if (mounted) {
      Navigator.pushNamed(context, PlanSelectionScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.embedded) {
      return content;
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.confirmExit(
          context,
          message:
              'Operations may be in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: BMJPalette.of(context).surface,
        body: Column(
          children: <Widget>[
            BMJGlassHeader(
              leading: Semantics(
                button: true,
                label: 'Back',
                child: IconButton(
                  onPressed: () async {
                    final bool shouldPop = await BackButtonHandler.confirmExit(
                      context,
                      message:
                          'Operations may be in progress. Are you sure you want to go back?',
                    );
                    if (shouldPop && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: BMJPalette.of(context).onSurface,
                  tooltip: 'Back',
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
        bottomNavigationBar: _subscriptions.isEmpty
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BMJTokens.pageMargin,
                    0,
                    BMJTokens.pageMargin,
                    BMJTokens.spaceMd,
                  ),
                  child: BMJGlassButton(
                    label: 'Change or add a plan',
                    icon: Icons.add,
                    onPressed: _browseSubscriptionPlans,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    final BMJPalette palette = BMJPalette.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: BMJEmptyState(
          icon: Icons.error_outline,
          title: 'Could not load subscriptions',
          message: _error,
          action: BMJGlassButton(
            label: 'Retry',
            expand: false,
            onPressed: _loadSubscriptions,
          ),
        ),
      );
    }

    if (_subscriptions.isEmpty) {
      return Center(
        child: BMJEmptyState(
          icon: Icons.subscriptions_outlined,
          title: 'No active subscriptions',
          message: 'Start a weekly or monthly plan and skip the daily queue.',
          action: BMJGlassButton(
            label: 'Browse plans',
            expand: false,
            icon: Icons.add_shopping_cart,
            onPressed: _browseSubscriptionPlans,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubscriptions,
      color: palette.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          BMJTokens.pageMargin,
          BMJTokens.spaceSm,
          BMJTokens.pageMargin,
          // Clear the floating bottom action bar.
          112,
        ),
        children: <Widget>[
          _buildPageIntro(palette),
          _buildCutoffNotice(palette),
          for (final Map<String, dynamic> subscription in _subscriptions)
            _buildSubscriptionCard(subscription),
        ],
      ),
    );
  }

  /// Stitch page intro: "Manage Subscriptions" + supporting line.
  Widget _buildPageIntro(BMJPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              'Manage Subscriptions',
              // Softened one step: a 28/800 heading over a warm page opened the
              // screen with a shout where the reference opens with a statement.
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                color: palette.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Review and adjust your active juice plans.',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Stitch "9 PM IST Cutoff" notice — the same rule the actions enforce.
  Widget _buildCutoffNotice(BMJPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: const Border(
            left: BorderSide(color: BMJTokens.orange, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: BMJTokens.orange,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '9 PM IST Cutoff',
                    style: AppTextStyles.textTheme.titleSmall?.copyWith(
                      color: palette.primaryEmphasis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Changes made after 9 PM will apply to the day after '
                    "tomorrow's delivery.",
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final BMJPalette palette = BMJPalette.of(context);
    final String status =
        subscription['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final String planName =
        (subscription['planName'] ?? subscription['planId'] ?? 'Unknown Plan')
            .toString();
    final String subscriptionId =
        (subscription['id'] ?? subscription['subscriptionId'] ?? '').toString();
    final bool isBefore9PM = _isBefore9PMIST();

    // Stitch marks state with a plain dot and a word. A tick inside a tinted
    // capsule added a third container to a card that only needs two.
    final (Color statusDot, Color statusInk, String statusLabel) =
        switch (status) {
      'ACTIVE' => (palette.accent, palette.accentText, 'Active'),
      'PAUSED' => (BMJTokens.tertiary, palette.onSurfaceVariant, 'Paused'),
      'CANCELLED' => (palette.error, palette.error, 'Cancelled'),
      _ => (palette.onSurfaceVariant, palette.onSurfaceVariant, status),
    };

    final String nextBillingLabel =
        formatEpochDate(subscription['nextBillingAt']);
    final String nextDeliveryLabel = nextDeliveryDateLabel(subscription);

    final int? quantity = quantityOf(subscription);
    final String periodUnit =
        subscription['billingPeriodUnit']?.toString() ?? '';
    final String billingLabel = switch (periodUnit) {
      'week' => 'Billed weekly',
      'month' => 'Billed monthly',
      'day' => 'Billed daily',
      'year' => 'Billed yearly',
      _ => periodUnit.isEmpty ? '' : 'Billed per $periodUnit',
    };
    final String planMeta = <String>[
      if (quantity != null) '$quantity ${quantity == 1 ? 'bottle' : 'bottles'}',
      if (billingLabel.isNotEmpty) billingLabel,
    ].join(' · ');

    final bool actionsBlocked =
        !isBefore9PM && (status == 'ACTIVE' || status == 'PAUSED');

    return BMJGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Stitch header: status on the left, plan reference on the right.
          Row(
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: statusDot,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: statusDot.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                statusLabel,
                style: AppTextStyles.textTheme.labelLarge?.copyWith(
                  color: statusInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  subscriptionId.isEmpty
                      ? 'Plan ID: —'
                      : 'Plan ID: #$subscriptionId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          // Stitch divides the status strip from the body with a hairline; that
          // single rule is what gives the card its two-part structure.
          Divider(
            height: BMJTokens.hairline,
            thickness: BMJTokens.hairline,
            color: palette.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            planName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // The plan name leads the body; the value panels sit one step above it
            // in weight, which is the reference's balance.
            style: AppTextStyles.textTheme.titleMedium?.copyWith(
              color: palette.onSurface,
            ),
          ),
          if (planMeta.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              planMeta,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _planStatBox(
                  palette,
                  label: 'Next delivery',
                  value: nextDeliveryLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _planStatBox(
                  palette,
                  label: 'Next billing',
                  value: nextBillingLabel,
                ),
              ),
            ],
          ),
          if (actionsBlocked) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.32),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: palette.primaryEmphasis,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Order changes reopen after 9 AM tomorrow',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: palette.primaryEmphasis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Stitch renders all three card actions at one height: `col-span-2 …
          // py-sm rounded-lg` (36 dp, 8 dp radius) for the primary, and half-width
          // 36 dp for Pause/Cancel. A 52 dp page CTA inside the card made the
          // action louder than the card holding it.
          BMJGlassButton.inCard(
            label: 'Modify plan',
            variant: BMJButtonVariant.primary,
            icon: Icons.edit_outlined,
            onPressed: _browseSubscriptionPlans,
          ),
          if (status == 'ACTIVE' || status == 'PAUSED') ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: BMJGlassButton.inCard(
                    label: status == 'ACTIVE' ? 'Pause' : 'Resume',
                    variant: BMJButtonVariant.neutral,
                    icon: status == 'ACTIVE'
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onPressed: isBefore9PM
                        ? () => status == 'ACTIVE'
                            ? _pauseSubscription(subscriptionId, planName)
                            : _resumeSubscription(subscriptionId, planName)
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: BMJGlassButton.inCard(
                    label: 'Cancel',
                    variant: BMJButtonVariant.danger,
                    icon: Icons.cancel_outlined,
                    onPressed: () =>
                        _cancelSubscription(subscriptionId, planName),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Stitch inner stat box (NEXT DELIVERY / NEXT BILLING).
  Widget _planStatBox(
    BMJPalette palette, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        // A sunken panel: the reference sets these boxes a step *below* the card,
        // so the delivery and billing figures read as the card's payload rather
        // than as two more raised chips.
        color: palette.surfaceDeep.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: palette.outlineVariant),
      ),
      child: BMJStatTile(
        value: value,
        label: label,
        valueMaxLines: 2,
        accent: palette.onSurface,
        // The loudest text inside the card, as in the reference.
        valueStyle: BMJType.statNum.copyWith(
          fontSize: 22,
          height: 1.2,
          color: palette.onSurface,
        ),
      ),
    );
  }
}
