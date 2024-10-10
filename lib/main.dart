import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/CartBloc/CartBloc.dart';
import 'package:lush/getIt.dart';
import 'package:lush/views/models/model.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'bloc/AuthBloc/AuthBloc.dart';
import 'views/all_Screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'views/models/User.dart';

void main() {
  // Bloc.observer = AuthenticationBlocObserver();
  registerRepositories();
  runApp(
    MultiBlocProvider(providers: [
      BlocProvider<AuthenticationBloc>(
          lazy: false, create: (_) => AuthenticationBloc()..add(AutoLogIn())),
      // BlocProvider<CartBloc>(lazy: false, create: (_) => CartBloc())
    ], child: const LushApp()),
  );
}

class LushApp extends StatelessWidget {
  const LushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigationKey,
      // home: const SplashScreen(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/splash': (_) => const SplashScreen(),
        '/home2': (_) => const HomePage2(),
        // '/home': (_) => const HomePage(),
        '/menu': (_) => const Menu(),
        '/subscriptions': (_) => const Subscription(),
        '/mobileNumberPage': (_) => const MobileNumberPage(),
        '/otp': (_) => const OTPLoginPage(),
        // '/signup': (context) => const SignUpScreen(user:),
      },
      onGenerateRoute: (settings) {
        if (settings.name == DetailPage.routeName) {
          final args = settings.arguments as DetailScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return DetailPage(
                args.p,
              );
            },
          );
        } else if (settings.name == SignUpScreen.routeName) {
          final args = settings.arguments as SignUpPageArguments;
          return MaterialPageRoute(
            builder: (context) {
              return SignUpScreen(
                user: args.user,
              );
            },
          );
        } else if (settings.name == AddressScreen.routeName) {
          final args = settings.arguments as AddresScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return AddressScreen(
                user: args.user,
              );
            },
          );
        } else if (settings.name == Payments.routeName) {
          final args = settings.arguments as PaymentScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return Payments(
                  amount: args.amount, description: args.description);
            },
          );
        }
        {
          return null;
        }
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return const LoginPage();
          },
        );
      },
      title: 'bookMyJuice',
    );
  }
}

// const LushApp({super.key});

class DetailScreenArguments {
  final Product p;

  DetailScreenArguments(this.p);
}

class SignUpPageArguments {
  final User user;

  SignUpPageArguments(this.user);
}

class AddresScreenArguments {
  final User user;

  AddresScreenArguments(this.user);
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
