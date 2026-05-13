import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/services/firebase_notification_service.dart';
import 'package:lush/services/firebase_options.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/google_sign_in.dart';
import 'package:lush/views/screens/checkout_screen.dart';
import 'package:lush/views/screens/google_signup_screen.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:rive/rive.dart';
import 'package:toastification/toastification.dart';

import 'CartRepository/cart_repository.dart';
import 'bloc/AuthBloc/auth_bloc.dart';
import 'bloc/AuthBloc/auth_events.dart';
import 'bloc/AuthBloc/auth_state.dart';
import 'bloc/CartBloc/cart_bloc.dart';
import 'bloc/CartBloc/cart_event.dart';
// Product Catalog BLoC
import 'bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'bloc/ProductsBloc/products_bloc.dart' as ProductsBloc;
import 'bloc/SubscriptionBloc/subscription_bloc.dart';
// Enhanced BLoCs for additional functionality
import 'bloc/UserBloc/user_bloc.dart';
import 'get_it.dart';
import 'views/all_screens.dart';
import 'views/models/model.dart';
import 'views/screens/address_entry_screen.dart';
import 'views/screens/create_password_screen.dart';
import 'views/screens/day_wise_schedule_screen.dart';
import 'views/screens/delete_account_screen.dart';
import 'views/screens/email_entry_after_phone_screen.dart';
import 'views/screens/email_signup_screen.dart';
import 'views/screens/email_verification_after_phone_screen.dart';
import 'views/screens/email_verification_screen.dart';
import 'views/screens/forgot_password_page.dart';
import 'views/screens/forgot_password_screen.dart';
import 'views/screens/google_phone_entry_screen.dart';
import 'views/screens/invoice_view_screen.dart';
import 'views/screens/link_google_account_screen.dart';
import 'views/screens/my_account_page.dart';
import 'views/screens/notifications.dart';
import 'views/screens/order_history_screen.dart';
import 'views/screens/phone_entry_after_email_screen.dart';
import 'views/screens/phone_login_screen.dart';
import 'views/screens/phone_otp_verification_screen.dart';
import 'views/screens/phone_signup_screen.dart';
import 'views/screens/product_catalog_screen.dart';
import 'views/screens/reset_password_email_screen.dart';
import 'views/screens/reset_password_mobile_screen.dart';
// New unified signup flow screens
import 'views/screens/signup_method_selection_screen.dart';
import 'views/screens/subscription_management_screen.dart';
import 'views/screens/dashboard.dart'; // For DashboardMode

void main() async {
  // 1. MUST be the first thing called
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Now you can safely call your background setup
  // Setup FCM background message handler before runApp()
  FirebaseNotificationService.setupBackgroundHandler();

  await _initializeApp();
  runApp(const BookMyJuiceApp());
}

Future<void> _initializeApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase (required for FCM and Firebase Phone Auth)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Google Sign-In
    await GoogleSignInHelper.instance.initialize();

    // Initialize error handling
    _initializeErrorHandling();

    // Register dependencies
    registerRepositories();

    // Initialize FCM push notification service (secondary layer)
    await FirebaseNotificationService.instance.initialize();

    await RiveNative.init(); // Required for 0.14.x

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (kDebugMode) {
      print('[INFO] App initialization completed successfully');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('[ERROR] App initialization failed: $e');
      print('StackTrace: $stackTrace');
    }
    rethrow;
  }
}

void _initializeErrorHandling() {
  // Set up global BLoC observer
  Bloc.observer = AuthenticationBlocObserver();

  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('[ERROR] Flutter Error: ${details.exception}');
      print('StackTrace: ${details.stack}');
    }
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('[ERROR] Platform Error: $error');
      print('StackTrace: $stack');
    }
    return true;
  };
}

class BookMyJuiceApp extends StatelessWidget {
  const BookMyJuiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 Pro dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // Existing AuthenticationBloc
            BlocProvider<AuthenticationBloc>(
              lazy: false,
              create: (_) => AuthenticationBloc()..add(AutoLogIn()),
            ),
            // Existing CartBloc
            BlocProvider<CartBloc>(
              lazy: false,
              create: (_) =>
                  CartBloc(getIt.get<CartRepository>())..add(LoadCart()),
            ),
            // Product Catalog BLoC (NEW)
            BlocProvider<ProductCatalogBloc>(
              lazy: false,
              create: (_) => ProductCatalogBloc(),
            ),
            // Enhanced BLoCs for additional functionality
            BlocProvider<UserBloc>(
              create: (context) => UserBloc(),
            ),
            BlocProvider<SubscriptionBloc>(
              create: (context) => SubscriptionBloc(),
            ),
            BlocProvider<ProductsBloc.ProductsBloc>(
              create: (context) => ProductsBloc.ProductsBloc()
                ..add(const ProductsBloc.LoadProducts()),
            ),
            // Theme management
            BlocProvider<ThemeCubit>(
              lazy: false,
              create: (context) {
                final cubit = ThemeCubit();
                cubit.loadPreference();
                return cubit;
              },
            ),
          ],
          child: ToastificationWrapper(
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return MaterialApp(
                  title: 'BookMyJuice',
                  debugShowCheckedModeBanner: false,
                  navigatorKey: NavigationService.navigationKey,
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [
                    Locale('en', 'US'),
                    Locale('en', 'GB'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: ThemeState.lightTheme,
                  darkTheme: ThemeState.darkTheme,
                  themeMode: themeState.resolvedThemeMode,
              initialRoute: '/',
              routes: {
                '/': (_) => const AuthWrapper(),
                '/mobileNumberPage': (_) => MobileNumberPage(),
                '/phone-login': (_) => const PhoneLoginScreen(),
                '/otp': (_) => OTPLoginPage(),
                // '/otpSignUpScreen': (_) => OTPSignUpScreen(),
                '/forgotPasswordPage': (_) => ForgotPasswordPage(),
                '/forgot-password': (_) => ForgotPasswordScreen(),
                '/reset-password-mobile-otp': (_) => ResetPasswordMobileScreen(),
                '/reset-password-email-code': (_) => ResetPasswordEmailScreen(),
                '/day-wise-schedule': (_) => DayWiseScheduleScreen(
                      availableJuices: [],
                      selectedPlan: {},
                    ),
                '/delete-account': (_) => const DeleteAccountScreen(),
                '/orders': (_) => const OrderHistoryPage(),
                // New routes for enhanced navigation
                '/manage-subscriptions': (_) =>
                    const SubscriptionManagementScreen(),
                '/order-history': (_) => const OrderHistoryScreen(),
                '/invoices': (_) => const InvoiceViewScreen(),
                // New unified signup flow routes
                '/signup-method-selection': (_) =>
                    const SignupMethodSelectionScreen(),
                '/email-signup': (_) => const EmailSignupScreen(),
                '/email-verification': (_) => const EmailVerificationScreen(),
                '/phone-entry-after-email': (_) =>
                    const PhoneEntryAfterEmailScreen(),
                '/phone-signup': (_) => const PhoneSignupScreen(),
                '/phone-otp-verification': (_) =>
                    const PhoneOtpVerificationScreen(),
                '/email-entry-after-phone': (_) =>
                    const EmailEntryAfterPhoneScreen(),
                '/email-verification-after-phone': (_) =>
                    const EmailVerificationAfterPhoneScreen(),
                '/google-signup': (_) => const GoogleSignupScreen(),
                '/google-phone-entry': (_) => const GooglePhoneEntryScreen(),
                '/address-entry': (_) => const AddressEntryScreen(),
                '/create-password': (_) => const CreatePasswordScreen(),
                '/login': (_) => const LoginPage(
                    toast_message: '', toast_heading: ''),
                '/dashboard': (_) => Dashboard(),
                '/product-catalog': (_) => ProductCatalogScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/myaccount') {
                  return MaterialPageRoute(builder: (_) {
                    return MyAccountPage(settings.arguments as String);
                  });
                }
                if (settings.name == '/subscriptions') {
                  return MaterialPageRoute(
                    builder: (_) {
                      return Subscription(
                        settings.arguments as SubscriptionPageUrlArgument,
                      );
                    },
                  );
                } else if (settings.name == "/productDetails") {
                  return MaterialPageRoute(
                    builder: (_) {
                      return DetailPage(
                        settings.arguments as Product,
                      );
                    },
                  );
                } else if (settings.name == '/notifications') {
                  return MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  );
                } else if (settings.name == '/cart') {
                  return MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  );
                } else if (settings.name == '/checkout') {
                  return MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                        checkoutUrl: settings.arguments as String),
                  );
                } else if (settings.name == '/menu') {
                  return MaterialPageRoute(
                    builder: (_) => const Menu(),
                  );
                } else if (settings.name == '/home') {
                  return MaterialPageRoute(
                    builder: (_) => Dashboard(),
                  );
                } else {
                  return null;
                }
              },
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context).textScaler.clamp(
                          minScaleFactor: 0.8,
                          maxScaleFactor: 1.2,
                        ),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  },
);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        // ── Authenticated: Full Dashboard ──
        if (state is AuthenticationSuccess) {
          return Dashboard(mode: DashboardMode.full);
        }

        // ── Signup flow continues ──
        if (state is SignUpStarted) {
          return SignUpScreen(user: state.user);
        }

        // ── Google linking flow ──
        if (state is GoogleLinkRequired) {
          return LinkGoogleAccountScreen(
            googleEmail: state.googleEmail,
            googleFirstName: state.googleFirstName,
            googleLastName: state.googleLastName,
            googleId: state.googleId,
            photoUrl: state.photoUrl,
          );
        }

        // ── Show public dashboard (no login needed) for all other states ──
        // Users can explore plans and one-time ordering.
        // Auth-gated actions will show login prompt.
        //
        // States handled by this branch:
        //   AutoLoginFailed, LogInFailed, SignUpFailed, SignUpSuccessful,
        //   LoggedOut, InternetIssue, AuthenticationInProgress, unknown
        //
        // Toasts for transient states are shown via pop-up / snackbar within
        // the Dashboard itself rather than requiring a LoginPage redirect.
        if (state is AuthenticationInProgress) {
          return Dashboard(mode: DashboardMode.public);
        }
        if (state is SignUpSuccessful) {
          return Dashboard(mode: DashboardMode.public);
        }
        return Dashboard(mode: DashboardMode.public);
      },
    );
  }
}


class DetailScreenArguments {
  final Product p;

  DetailScreenArguments(this.p);
}

class MyAccountPageUrl {
  final String url;

  MyAccountPageUrl(this.url);
}

class SubscriptionPageUrlArgument {
  final String premium_page_url, signature_page_url, delight_page_url;
  SubscriptionPageUrlArgument(
      {required this.premium_page_url,
      required this.signature_page_url,
      required this.delight_page_url});
}

class SignUpScreenArguments {
  // final user user;
  SignUpScreenArguments();
}

class PaymentScreenArguments {
  final int amount;
  final String description;

  PaymentScreenArguments(this.amount, this.description);
}

class AuthenticationBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print('[DEBUG] BLoC Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print('[DEBUG] BLoC Change: ${bloc.runtimeType} - $change');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print('[DEBUG] BLoC Transition: ${bloc.runtimeType} - $transition');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      print('[ERROR] BLoC Error: ${bloc.runtimeType} - $error');
      print('StackTrace: $stackTrace');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      print('[DEBUG] BLoC Closed: ${bloc.runtimeType}');
    }
  }
}
