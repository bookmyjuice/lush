// import 'dart:js';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lush/models/model.dart';
import 'package:lush/screens/AddressScreen.dart';
import 'package:lush/screens/EnterMobileNumber.dart';
import 'package:lush/screens/HomePage.dart';
import 'package:lush/screens/HomePage2.dart';
import 'package:lush/screens/Menu.dart';
import 'package:lush/screens/OTPloginPage.dart';
import 'package:lush/screens/SignUpScreen.dart';
import 'package:lush/screens/SplashPage.dart';
import 'package:lush/screens/SubscriptionScreen.dart';
import 'package:lush/screens/detail.dart';
import 'package:lush/screens/loginPage.dart';
import 'package:lush/screens/paymentScreen.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'UserRepository/userRepository.dart';
import 'bloc/AuthBloc.dart';

// import 'events/AuthEvents.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:appwrite/appwrite.dart';

import 'models/User.dart';

void main() {
  // Bloc.observer = AuthenticationBlocObserver();
  runApp(
    RepositoryProvider(
      create: (context) => UserRepository(),
      child: MultiBlocProvider(providers: [
        BlocProvider<AuthenticationBloc>(
            lazy: false,
            create: (_) => AuthenticationBloc(
                userRepository: RepositoryProvider.of<UserRepository>(_)))
      ], child: const LushApp()),
    ),
  );
}

class LushApp extends StatelessWidget {
  const LushApp({super.key});

  // int _main_counter=0;
  @override
  Widget build(BuildContext context) {
    // _main_counter++;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigationKey,
      routes: {
        '/': (_) => const LoginPage(),
        // '/login': (context) => const LoginPage(),
        '/splash': (_) => const SplashScreen(),
        '/home2': (_) => const HomePage2(),
        '/home': (_) => const HomePage(),
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
      title: 'Lush',
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
