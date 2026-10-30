import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/screens/subscription_management_screen.dart';

/// The `Subscription` destination of the dashboard.
///
/// Renders the existing subscription experience without its own `Scaffold`
/// app bar (P0-1: the tab used to open the order list). `/manage-subscriptions`
/// still pushes the full screen.
///
/// Signed-out visitors get a sign-in / browse-plans state instead of a
/// guaranteed 401 from the subscriptions API.
class SubscriptionTab extends StatelessWidget {
  const SubscriptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is! AuthenticationSuccess) {
          return const _SignedOutState();
        }
        return const SubscriptionManagementScreen(embedded: true);
      },
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              size: 64,
              color: AppColors.primaryGreen.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No subscription yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to see your plan, deliveries and pause options, or '
              'browse the plans first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: const Key('subscription_tab_browse_plans'),
                onPressed: () =>
                    Navigator.pushNamed(context, '/plan-selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Browse plans'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
