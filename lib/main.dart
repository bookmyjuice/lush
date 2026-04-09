import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/views/models/googleSignIn.dart';
import 'package:lush/views/screens/CheckoutScreen.dart';
import 'package:lush/views/screens/GoogleSignupScreen.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:rive/rive.dart';
import 'package:toastification/toastification.dart';

import 'CartRepository/cartRepository.dart';
import 'bloc/AuthBloc/AuthBloc.dart';
import 'bloc/AuthBloc/AuthEvents.dart';
import 'bloc/AuthBloc/AuthState.dart';
import 'bloc/CartBloc/CartBloc.dart';
import 'bloc/CartBloc/cartEvent.dart';
// Product Catalog BLoC
import 'bloc/ProductCatalogBloc/ProductCatalogBloc.dart';
import 'bloc/ProductsBloc/ProductsBloc.dart' as ProductsBloc;
import 'bloc/SubscriptionBloc/subscription_bloc.dart';
// Enhanced BLoCs for additional functionality
import 'bloc/UserBloc/UserBloc.dart';
import 'getIt.dart';
import 'views/all_Screens.dart';
import 'views/models/model.dart';
import 'views/screens/AddressEntryScreen.dart';
import 'views/screens/CreatePasswordScreen.dart';
import 'views/screens/EmailEntryAfterPhoneScreen.dart';
import 'views/screens/EmailSignupScreen.dart';
import 'views/screens/EmailVerificationAfterPhoneScreen.dart';
import 'views/screens/EmailVerificationScreen.dart';
import 'views/screens/ForgotPasswordPage.dart';
import 'views/screens/GooglePhoneEntryScreen.dart';
import 'views/screens/InvoiceViewScreen.dart';
import 'views/screens/MyAccountPage.dart';
import 'views/screens/OrderHistoryScreen.dart';
import 'views/screens/PhoneEntryAfterEmailScreen.dart';
import 'views/screens/PhoneOtpVerificationScreen.dart';
import 'views/screens/PhoneSignupScreen.dart';
import 'views/screens/ProductCatalogScreen.dart';
// New unified signup flow screens
import 'views/screens/SignupMethodSelectionScreen.dart';
import 'views/screens/SubscriptionManagementScreen.dart';
import 'views/screens/notifications.dart';

void main() async {
  await _initializeApp();
  runApp(const BookMyJuiceApp());
}

Future<void> _initializeApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Google Sign-In
    await GoogleSignInHelper.instance.initialize();

    // Initialize error handling
    _initializeErrorHandling();

    // Register dependencies
    registerRepositories();

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
          ],
          child: ToastificationWrapper(
            child: MaterialApp(
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
              theme: ThemeData(
                fontFamily: 'Roboto',
                primarySwatch: Colors.blue,
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(fontFamily: 'Roboto'),
                  bodyMedium: TextStyle(fontFamily: 'Roboto'),
                  displayLarge: TextStyle(fontFamily: 'Roboto'),
                  displayMedium: TextStyle(fontFamily: 'Roboto'),
                  displaySmall: TextStyle(fontFamily: 'Roboto'),
                  headlineLarge: TextStyle(fontFamily: 'Roboto'),
                  headlineMedium: TextStyle(fontFamily: 'Roboto'),
                  headlineSmall: TextStyle(fontFamily: 'Roboto'),
                  titleLarge: TextStyle(fontFamily: 'Roboto'),
                  titleMedium: TextStyle(fontFamily: 'Roboto'),
                  titleSmall: TextStyle(fontFamily: 'Roboto'),
                  labelLarge: TextStyle(fontFamily: 'Roboto'),
                  labelMedium: TextStyle(fontFamily: 'Roboto'),
                  labelSmall: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              initialRoute: '/',
              routes: {
                '/': (_) => const AuthWrapper(),
                '/mobileNumberPage': (_) => MobileNumberPage(),
                '/otp': (_) => OTPLoginPage(),
                // '/otpSignUpScreen': (_) => OTPSignUpScreen(),
                '/forgotPasswordPage': (_) => ForgotPasswordPage(),
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
        if (state is AuthenticationSuccess) {
          return Dashboard();
        } else if (state is AutoLoginFailed) {
          return LoginPage(
              toast_message: state.toast_message,
              toast_heading: state.toast_heading);
        } else if (state is LogInFailed) {
          return LoginPage(
              toast_message: state.toast_message,
              toast_heading: state.toast_heading);
        } else if (state is SignUpFailed) {
          return LoginPage(
              toast_message: state.error, toast_heading: "SignUp Failed!");
        } else if (state is SignUpStarted) {
          return SignUpScreen(user: state.user);
        } else if (state is SignUpSuccessful) {
          return LoginPage(
              toast_heading: "Signup Successfull!",
              toast_message: "Please login to continue..");
        } else if (state is AuthenticationInProgress) {
          return const SplashScreen();
        } else if (state is LoggedOut) {
          return LoginPage(
              toast_heading: "You've logged out!",
              toast_message: "Please login to continue..");
        } else if (state is InternetIssue) {
          return LoginPage(
              toast_message: state.toast_message,
              toast_heading: state.toast_heading);
        } else {
          return const SplashScreen();
        }
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
