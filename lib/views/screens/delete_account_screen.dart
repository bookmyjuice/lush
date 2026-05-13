import 'package:flutter/material.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:lush/theme/app_colors.dart';

/// #9 UX: Delete Account Screen
/// Allows user to soft-delete their account with 30-day grace period.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _userRepository = UserRepository();
  bool _isLoading = false;
  bool _confirmed = false;

  Future<void> _deleteAccount() async {
    if (!_confirmed) {
      _showConfirmationDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _userRepository.deleteAccount();

      setState(() => _isLoading = false);

      if (mounted) {
        if (result.contains('deleted successfully')) {
          toastification.show(
            title: const Text('Account Deleted'),
            description: const Text(
              'Your account has been deleted. You have 30 days to recover it by contacting support.',
            ),
            type: ToastificationType.warning,
          );
          // Navigate to login and clear navigation stack
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          toastification.show(
            title: const Text('Deletion Failed'),
            description: Text(result),
            type: ToastificationType.error,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        toastification.show(
          title: const Text('Error'),
          description: Text('Failed to delete account: $e'),
          type: ToastificationType.error,
        );
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 16),
            Text(
              '• You will lose access to your subscriptions and order history\n'
              '• Your data will be soft-deleted and can be recovered within 30 days\n'
              '• After 30 days, your data will be permanently deleted\n'
              '• To recover your account within 30 days, contact support',
              style: TextStyle(fontSize: 13, color: AppColors.darkGrey, fontFamily: 'Roboto'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _confirmed = true);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.confirmExit(
          context,
          title: 'Leave Account Deletion?',
          message: 'Are you sure you want to go back? Your account will not be deleted.',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.delete_forever, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Delete Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 16),
              Text(
                'This action will soft-delete your account. Your data will be retained for 30 days in case you change your mind.',
                style: TextStyle(fontSize: 14, color: AppColors.darkGrey, fontFamily: 'Roboto'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'What you will lose:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red[800], fontFamily: 'Roboto'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLossItem('Access to active subscriptions'),
                    _buildLossItem('Order history and invoices'),
                    _buildLossItem('Saved delivery addresses'),
                    _buildLossItem('Cart items and preferences'),
                    const SizedBox(height: 12),
                    Text(
                      'Recovery: Contact support within 30 days to recover your account.',
                      style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary!, fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text(
                          'Delete My Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLossItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], fontFamily: 'Roboto'),
            ),
          ),
        ],
      ),
    );
  }
}
