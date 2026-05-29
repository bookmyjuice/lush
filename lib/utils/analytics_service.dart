import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService();

  static FirebaseAnalytics? _analyticsInstance;

  static FirebaseAnalytics get _analytics =>
      _analyticsInstance ?? FirebaseAnalytics.instance;

  @visibleForTesting
  static void setAnalyticsForTesting(FirebaseAnalytics analytics) {
    _analyticsInstance = analytics;
  }

  @visibleForTesting
  static void resetAnalyticsForTesting() {
    _analyticsInstance = null;
  }

  static Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  static Future<void> logSignup({String? referralUsed}) async {
    await _analytics.logEvent(name: 'signup', parameters: {
      'referral_used': referralUsed != null ? 'yes' : 'no',
    });
  }

  static Future<void> logItemViewed({
    required String itemId,
    required String itemName,
    required String family,
  }) async {
    await _analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: family,
        ),
      ],
    );
  }

  static Future<void> logSearchPerformed(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  static Future<void> logFamilySelected(String family) async {
    await _analytics.logEvent(name: 'family_selected', parameters: {'family': family});
  }

  static Future<void> logSubscriptionStarted({
    required String planId,
    required double value,
  }) async {
    await _analytics.logEvent(name: 'subscription_started', parameters: {
      'plan_id': planId,
      'value': value,
    });
  }

  static Future<void> logSubscriptionPaused(String planId) async {
    await _analytics.logEvent(name: 'subscription_paused', parameters: {'plan_id': planId});
  }

  static Future<void> logSubscriptionCancelled({
    required String planId,
    required String reason,
  }) async {
    await _analytics.logEvent(name: 'subscription_cancelled', parameters: {
      'plan_id': planId,
      'reason': reason,
    });
  }

  static Future<void> logOrderPlaced({
    required double value,
    required int itemCount,
  }) async {
    await _analytics.logEvent(name: 'order_placed', parameters: {
      'value': value,
      'item_count': itemCount,
    });
  }

  static Future<void> logReorderTapped(String orderId) async {
    await _analytics.logEvent(name: 'reorder_tapped', parameters: {'order_id': orderId});
  }

  static Future<void> logReferralShared() async {
    await _analytics.logShare(
      contentType: 'referral_code',
      itemId: 'referral',
      method: 'share_sheet',
    );
  }

  static Future<void> logNotificationTapped(String type) async {
    await _analytics.logEvent(name: 'notification_tapped', parameters: {'notification_type': type});
  }
}