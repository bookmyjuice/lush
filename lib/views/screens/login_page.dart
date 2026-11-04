import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/app_theme.dart';
import 'package:lush/views/models/google_sign_in.dart';
import 'package:toastification/toastification.dart';

/// Unified Authentication Screen
///
/// Two prominent tabs at the top: [Sign In] | [Sign Up]
///
/// **Sign In tab:** Google Sign-In and Phone OTP only (no passwords)
/// **Sign Up tab:** Two method cards → Phone (OTP) and Google signup flows
///
/// V1 launch: email/password signup and sign-in were removed from the tree
/// (`AUTH_SIMPLIFICATION_PLAN.md` A2). Onboarding is Phone (OTP) or Google.
///
/// Design System: Uses AppColors.primaryOrange (#FF8C42) as primary brand color.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.toastMessage,
    required this.toastHeading,
  });

  final String toastMessage;
  final String toastHeading;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // ── Tab Controller ──
  late TabController _tabController;
  int _currentTabIndex = 0;

  // ── Sign In Form ──
  bool _dialogShown = false;

  // ── Sign Up State ──
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    if (widget.toastHeading.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          icon: const Icon(Icons.error),
          alignment: Alignment.center,
          title: Text(widget.toastHeading),
          description: Text(widget.toastMessage),
          type: ToastificationType.error,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is AuthenticationSuccess ||
            current is LogInFailed ||
            current is SignUpFailed ||
            current is AutoLoginFailed,
        listener: (context, state) async {
          if (state is AuthenticationSuccess) {
            _dialogShown = true;
            // Only dismiss this screen when it is the route on top. In the
            // phone-OTP flow the verification screen has already replaced the
            // whole stack with /dashboard, so popping here removed the
            // dashboard itself and left an empty navigator — the black screen.
            final ModalRoute<dynamic>? route = ModalRoute.of(context);
            if (route?.isCurrent ?? false) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
            }
            return;
          }
          if ((state is LogInFailed) && !_dialogShown) {
            _dialogShown = true;
            toastification.show(
              title: const Text('Login Failed'),
              description:
                  const Text('Please check your credentials and try again.'),
              type: ToastificationType.error,
            );
          }
          if (state is SignUpFailed) {
            _dialogShown = true;
            toastification.show(
              title: Text(state.errorHeading),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          }
          if (state is AutoLoginFailed) {
            _dialogShown = true;
            toastification.show(
              title: const Text('Session Expired'),
              description: const Text('Please sign in to continue.'),
              type: ToastificationType.error,
            );
          }
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Logo & Title ──
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 100,
                  width: 200,
                  child: Image.asset('assets/bmjlogo.png'),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Fresh Juices, Delivered Daily',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Tab Bar: Sign In | Sign Up ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.lg * 1.875),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg * 1.875),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primaryOrange,
                    unselectedLabelColor: AppColors.white,
                    labelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                    unselectedLabelStyle:
                        AppTextStyles.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    dividerHeight: 0,
                    tabs: const [
                      Tab(key: Key('login_tab_sign_in'), text: 'Sign In'),
                      Tab(key: Key('login_tab_sign_up'), text: 'Sign Up'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Tab Content ──
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSignInTab(),
                      _buildSignUpTab(),
                    ],
                  ),
                ),

                // Guest entry: the dashboard is browsable without an account,
                // so signing in is a choice rather than a gate.
                TextButton(
                  key: const Key('login_continue_as_guest'),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/dashboard'),
                  child: Text(
                    'Continue without signing in',
                    style: AppTextStyles.textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIGN IN TAB
  // ═══════════════════════════════════════════════════════

  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Sign in with Google or your phone number',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          KeyedSubtree(
            key: const Key('login_google_button'),
            child: Semantics(
              label: 'Continue with Google',
              child: _buildAltLoginButton(
                icon: FontAwesomeIcons.google,
                label: 'Continue with Google',
                color: AppColors.white,
                iconColor: AppColors.error,
                onTap: _isGoogleLoading ? () {} : _handleGoogleSignIn,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          KeyedSubtree(
            key: const Key('login_phone_button'),
            child: Semantics(
              label: 'Continue with Phone',
              child: _buildAltLoginButton(
                icon: FontAwesomeIcons.mobileScreenButton,
                label: 'Continue with Phone',
                color: AppColors.white,
                iconColor: AppColors.secondaryTeal,
                onTap: () {
                  Navigator.of(context).pushNamed('/phone-entry');
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No password needed - we text you a 6-digit code.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(1);
                },
                child: Text(
                  'Sign Up',
                  style: AppTextStyles.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ============================================================
  // SIGN UP TAB
  // ============================================================

  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Heading ──
          Text(
            'Create Your Account',
            style: AppTextStyles.textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose your preferred signup method',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg + AppSpacing.xs),

          // V1 onboarding is Phone (OTP) or Google. The email/password signup
          // screens no longer exist; retired routes redirect to this surface.

          // ── Sign up with Phone ──
          Semantics(
            label: 'Sign up with Phone',
            child: _buildSignupMethodCard(
              icon: Icons.phone_outlined,
              iconColor: AppColors.success,
              title: 'Sign up with Phone',
              subtitle: 'Enter your mobile number',
              onTap: () {
                Navigator.pushNamed(context, '/phone-entry');
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Sign up with Google ──
          Semantics(
            label: 'Sign up with Google',
            child: _buildSignupMethodCard(
              icon: FontAwesomeIcons.google,
              iconColor: AppColors.error,
              title: 'Sign up with Google',
              subtitle: 'Quick signup with your Google account',
              onTap: _isGoogleLoading ? null : _handleGoogleSignUp,
              isLoading: _isGoogleLoading,
            ),
          ),
          const SizedBox(height: AppSpacing.lg + AppSpacing.xs),

          // ── Divider ──
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.white54, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'OR',
                  style: AppTextStyles.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white70,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.white54, thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Switch to Sign In ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(0);
                },
                child: Text(
                  'Sign In',
                  style: AppTextStyles.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIGN IN ACTIONS
  // ═══════════════════════════════════════════════════════

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Show loading indicator
      showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );

      // Attempt Google Login
      final googleUser = await GoogleSignInHelper.instance.signIn();

      // Remove loading indicator
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (googleUser != null) {
        BlocProvider.of<AuthenticationBloc>(context).add(
          const ChooseSignupMethod(method: 'google'),
        );
        Navigator.pushNamed(
          context,
          '/google-signup',
          arguments: googleUser,
        );
      }
    } catch (e) {
      toastification.show(
        title: const Text('Google Sign-Up Failed'),
        description: Text(e.toString()),
        type: ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // The Google Sign-In account picker is shown inside googleSignIn_() in the BLoC handler,
    // so we dispatch the event directly to avoid showing the picker twice.
    setState(() => _isGoogleLoading = true);
    try {
      if (!mounted) return;
      BlocProvider.of<AuthenticationBloc>(context).add(const GoogleSignIn());
    } catch (e) {
      debugPrint('❌ Google Sign-In from login page failed: $e');
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // COMMON WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════

  /// Social / Alternative login button (Google, Phone OTP)
  Widget _buildAltLoginButton({
    required FaIconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.white.withValues(alpha: 0.15),
        foregroundColor: AppColors.white,
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the icon widget for a signup method card.
  /// Handles both Material [IconData] and FontAwesome [FaIconData] icons.
  Widget _buildCardIcon(dynamic icon, Color iconColor) {
    if (icon is FaIconData) {
      return FaIcon(icon, size: 22, color: iconColor);
    }
    return Icon(icon as IconData, size: 22, color: iconColor);
  }

  /// Signup method card (Email, Phone, Google)
  Widget _buildSignupMethodCard({
    required dynamic icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg - 6),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm + 4),
              ),
              child: _buildCardIcon(icon, iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
