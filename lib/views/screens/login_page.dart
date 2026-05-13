import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/google_sign_in.dart';
import 'package:toastification/toastification.dart';
import 'package:lush/theme/app_text_styles.dart';

/// Unified Authentication Screen
///
/// Two prominent tabs at the top: [Sign In] | [Sign Up]
///
/// **Sign In tab:** Email + Password (primary), Google & Phone OTP (secondary)
/// **Sign Up tab:** Three method cards → Email, Phone, Google signup flows
///
/// Design System: Uses AppColors.primaryOrange (#FF8C42) as primary brand color.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.toast_message,
    required this.toast_heading,
  });

  final String toast_message;
  final String toast_heading;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // ── Tab Controller ──
  late TabController _tabController;
  int _currentTabIndex = 0;

  // ── Sign In Form ──
  final _signInFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignInLoading = false;
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

    if (widget.toast_heading.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          icon: const Icon(Icons.error),
          closeButton: ToastCloseButton(),
          alignment: Alignment.center,
          title: Text(widget.toast_heading),
          description: Text(widget.toast_message),
          type: ToastificationType.error,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is LogInFailed ||
            current is SignUpFailed ||
            current is AutoLoginFailed,
        listener: (context, state) async {
          if ((state is LogInFailed) && !_dialogShown) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
              title: const Text('Login Failed'),
              description:
                  const Text('Please check your credentials and try again.'),
              type: ToastificationType.error,
            );
          }
          if (state is SignUpFailed) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
              title: Text(state.error_heading),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          }
          if (state is AutoLoginFailed) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
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
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Logo & Title ──
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  width: 200,
                  child: Image.asset('assets/bmjlogo.png'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fresh Juices, Delivered Daily',
                  style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tab Bar: Sign In | Sign Up ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primaryOrange,
                    unselectedLabelColor: AppColors.white,
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryOrange, fontFamily: 'Roboto'),
                    unselectedLabelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white, fontFamily: 'Roboto'),
                    dividerHeight: 0,
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Heading ──
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white, fontFamily: 'Roboto'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account',
              style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Email Field ──
            _buildWhiteTextField(
              controller: _emailController,
              hintText: 'Email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!isValidEmail(value.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password Field ──
            _buildWhiteTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 6),

            // ── Forgot Password ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/forgot-password");
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white, fontFamily: 'Roboto'),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Sign In Button ──
            _buildSignInButton(),
            const SizedBox(height: 20),

            // ── Divider ──
            Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.white54, thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70, fontFamily: 'Roboto'),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.white54, thickness: 1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Social / Alt Login Row ──
            Row(
              children: [
                // Google Login Button
                Expanded(
                  child: _buildAltLoginButton(
                    icon: FontAwesomeIcons.google,
                    label: 'Google',
                    color: AppColors.white,
                    iconColor: AppColors.error,
                    onTap: _handleGoogleSignIn,
                  ),
                ),
                const SizedBox(width: 12),
                // Phone OTP Login Button
                Expanded(
                  child: _buildAltLoginButton(
                    icon: FontAwesomeIcons.mobileScreenButton,
                    label: 'Phone OTP',
                    color: AppColors.white,
                    iconColor: AppColors.secondaryTeal,
                    onTap: () {
                      Navigator.of(context).pushNamed("/phone-login");
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Switch to Sign Up ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(1);
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIGN UP TAB
  // ═══════════════════════════════════════════════════════

  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Heading ──
          Text(
            'Create Your Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white, fontFamily: 'Roboto'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred signup method',
            style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Sign up with Email ──
          _buildSignupMethodCard(
            icon: Icons.email_outlined,
            iconColor: AppColors.info,
            title: 'Sign up with Email',
            subtitle: 'Enter your email address',
            onTap: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
                const ChooseSignupMethod(method: 'email'),
              );
              Navigator.pushNamed(context, '/email-signup');
            },
          ),
          const SizedBox(height: 12),

          // ── Sign up with Phone ──
          _buildSignupMethodCard(
            icon: Icons.phone_outlined,
            iconColor: AppColors.success,
            title: 'Sign up with Phone',
            subtitle: 'Enter your mobile number',
            onTap: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
                const ChooseSignupMethod(method: 'phone'),
              );
              Navigator.pushNamed(context, '/phone-signup');
            },
          ),
          const SizedBox(height: 12),

          // ── Sign up with Google ──
          _buildSignupMethodCard(
            icon: FontAwesomeIcons.google,
            iconColor: AppColors.error,
            title: 'Sign up with Google',
            subtitle: 'Quick signup with your Google account',
            onTap: _isGoogleLoading ? null : _handleGoogleSignUp,
            isLoading: _isGoogleLoading,
          ),
          const SizedBox(height: 28),

          // ── Divider ──
          Row(
            children: [
              const Expanded(
                child: Divider(color: Colors.white54, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70, fontFamily: 'Roboto'),
                ),
              ),
              const Expanded(
                child: Divider(color: Colors.white54, thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Switch to Sign In ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(0);
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIGN IN ACTIONS
  // ═══════════════════════════════════════════════════════

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSignInLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryOrange,
          elevation: 2,
          disabledBackgroundColor: AppColors.white.withOpacity(0.5),
          disabledForegroundColor: AppColors.primaryOrange.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSignInLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              )
            : Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryOrange, fontFamily: 'Roboto'),
              ),
      ),
    );
  }

  void _handleSignIn() {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isSignInLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    BlocProvider.of<AuthenticationBloc>(context).add(
      LogIn(email, password, false),
    );

    // Reset loading after a reasonable timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isSignInLoading = false);
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // SIGN UP ACTIONS
  // ═══════════════════════════════════════════════════════

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Show loading indicator
      showDialog(
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
        title: const Text('Google Sign-In Failed'),
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
    setState(() => _isSignInLoading = true);
    try {
      if (!mounted) return;
      BlocProvider.of<AuthenticationBloc>(context)
          .add(const GoogleSignIn());
    } catch (e) {
      debugPrint('❌ Google Sign-In from login page failed: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isSignInLoading = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // COMMON WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════

  /// White-background text field for Sign In form
  Widget _buildWhiteTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(fontSize: 15, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15, color: Colors.grey, fontFamily: 'Roboto'),
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 22),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

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
        backgroundColor: AppColors.white.withOpacity(0.15),
        foregroundColor: AppColors.white,
        side: BorderSide(color: AppColors.white.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white, fontFamily: 'Roboto'),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCardIcon(icon, iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white, fontFamily: 'Roboto'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.white.withOpacity(0.7),
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
                color: AppColors.white.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }
}





