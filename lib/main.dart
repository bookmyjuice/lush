import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/getIt.dart';
import 'package:lush/views/models/model.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'bloc/AuthBloc/AuthBloc.dart';
import 'views/all_Screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  // Bloc.observer = AuthenticationBlocObserver();
  registerRepositories();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationBloc>(
          lazy: false, create: (_) => AuthenticationBloc()..add(AutoLogIn())),
      // BlocProvider<CartBloc>(lazy: false, create: (_) => CartBloc())
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const AuthWrapper(),
      navigatorKey: NavigationService.navigationKey,
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthWrapper(),
      },
      //   '/login': (_) => const LoginPage(),
      //   '/splash': (_) => const SplashScreen(),
      //   '/home2': (_) => const HomePage2(),
      //   // '/home': (_) => const HomePage(),
      //   '/menu': (_) => const Menu(),
      //   '/subscriptions': (_) => const Subscription(),
      //   '/mobileNumberPage': (_) => const MobileNumberPage(),
      //   '/otp': (_) => const OTPLoginPage(),
      //   // '/signup': (context) => const SignUpScreen(user:),
      // },
      onGenerateRoute: (settings) {
        //   if (settings.name == DetailPage.routeName) {
        //     final args = settings.arguments as DetailScreenArguments;
        //     return MaterialPageRoute(
        //       builder: (context) {
        //         return DetailPage(
        //           args.p,
        //         );
        //       },
        //     );
        //   } else if (settings.name == SignUpScreen.routeName) {
        //     final args = settings.arguments as SignUpPageArguments;
        //     return MaterialPageRoute(
        //       builder: (context) {
        //         return SignUpScreen(
        //           user: args.user,
        //         );
        //       },
        //     );
        //   } else
        if (settings.name == AddressScreen.routeName) {
          final args = settings.arguments as AddresScreenArguments;
          return MaterialPageRoute(builder: (context) {
            return AddressScreen();
          });
        } else if (settings.name == SignUpScreen.routeName) {
          final args = settings.arguments as SignUpScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return SignUpScreen();
            },
          );
        }
        return null;
        //else if (settings.name == Payments.routeName) {
        //     final args = settings.arguments as PaymentScreenArguments;
        //     return MaterialPageRoute(
        //       builder: (context) {
        //         return Payments(
        //             amount: args.amount, description: args.description);
      },
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
        } else if (state is SignUpStarted) {
          return SignUpScreen();
        }
        return const SplashScreen();
      },

      // navigatorKey: NavigationService.navigationKey,
      // home: const SplashScreen(),
      // initialRoute: '/',
      // routes: {
      //   '/': (_) => const HomePage(),
      //   '/login': (_) => const LoginPage(),
      //   '/splash': (_) => const SplashScreen(),
      //   '/home2': (_) => const HomePage2(),
      //   // '/home': (_) => const HomePage(),
      //   '/menu': (_) => const Menu(),
      //   '/subscriptions': (_) => const Subscription(),
      //   '/mobileNumberPage': (_) => const MobileNumberPage(),
      //   '/otp': (_) => const OTPLoginPage(),
      //   // '/signup': (context) => const SignUpScreen(user:),
      // },
      // onGenerateRoute: (settings) {
      //   if (settings.name == DetailPage.routeName) {
      //     final args = settings.arguments as DetailScreenArguments;
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return DetailPage(
      //           args.p,
      //         );
      //       },
      //     );
      //   } else if (settings.name == SignUpScreen.routeName) {
      //     final args = settings.arguments as SignUpPageArguments;
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return SignUpScreen(
      //           user: args.user,
      //         );
      //       },
      //     );
      //   } else if (settings.name == AddressScreen.routeName) {
      //     final args = settings.arguments as AddresScreenArguments;
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return AddressScreen(
      //           user: args.user,
      //         );
      //       },
      //     );
      //   } else if (settings.name == Payments.routeName) {
      //     final args = settings.arguments as PaymentScreenArguments;
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return Payments(
      //             amount: args.amount, description: args.description);
      //       },
      //     );
      //   }
      //   {
      //     return null;
      //   }
      // },
      // onUnknownRoute: (settings) {
      //   return MaterialPageRoute(
      //     builder: (context) {
      //       return const LoginPage();
      //     },
      //   );
      // },
      // title: 'bookMyJuice',
    );
  }
}

// const LushApp({super.key});

class DetailScreenArguments {
  final Product p;

  DetailScreenArguments(this.p);
}

class SignUpScreenArguments {
  final user user;
  SignUpScreenArguments(this.user);
}

class AddresScreenArguments {
  // final User user;
  final String fname;
  final String lname;
  final String phone;
  final String email;

  AddresScreenArguments(
      {required this.email,
      required this.fname,
      required this.lname,
      required this.phone});
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
