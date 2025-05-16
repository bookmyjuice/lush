import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/getIt.dart';
import 'package:lush/views/all_Screens.dart';
import 'package:lush/views/models/model.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'bloc/AuthBloc/AuthBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

void main() {
  // Bloc.observer = AuthenticationBlocObserver();
  registerRepositories();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationBloc>(
          lazy: false, create: (_) => AuthenticationBloc()..add(AutoLogIn())),
      // BlocProvider<CartBloc>(lazy: false, create: (_) => CartBloc())
    ],
    child: ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: const AuthWrapper(),
        navigatorKey: NavigationService.navigationKey,
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthWrapper(),
          '/mobileNumberPage': (_) => MobileNumberPage(),
          '/otp': (_) => OTPLoginPage(),
          // '/subscriptions': (_) => Subscription()
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/subscriptions') {
            // final args = settings.arguments;
            return MaterialPageRoute(
              builder: (_) {
                final args = settings.arguments;
                return Subscription(
                  args as String,
                );
              },
            );
          } else if (settings.name == "/productDetails") {
            // final args = settings.arguments;
            return MaterialPageRoute(
              builder: (_) {
                final args = settings.arguments;
                return DetailPage(
                  args as Product,
                );
              },
            );
          } else {
            return null;
          }
        },
      ),
    ),
  ));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return Dashboard();
        } else if (state is LogInFailed) {
          return LoginPage();
        } else if (state is AuthError) {
          return LoginPage();
        } else if (state is SignUpFailed) {
          return LoginPage();
        } else if (state is SignUpStarted) {
          return SignUpScreen();
        } else if (state is SignUpSuccessful) {
          return LoginPage();
        } else if (state is AuthenticationInProgress) {
          return const SplashScreen();
        } else if (state is LoggedOut) {
          return LoginPage();
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

class SubscriptionPageUrlArgument {
  final String url;

  SubscriptionPageUrlArgument(this.url);
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
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print(transition);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print(error);
    }
    super.onError(bloc, error, stackTrace);
  }
}
