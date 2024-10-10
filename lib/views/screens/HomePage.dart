import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/views/all_Screens.dart';
import 'package:lush/views/screens/HomePage2.dart';

// import 'package:lush/screens/SignUpScreen.dart';
import '../../bloc/AuthBloc/AuthState.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // const HomePage({Key? key}) : super(key: key);

  //
  // final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is LogInFailed) {
        return const LoginPage();
      }
      if (state is AuthenticationSuccess) {
        return const HomePage2();
      } else if (state is AuthenticationFailure) {
        return SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 15,
                child: Center(
                    child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Auth Failure for ${state.user.email}",
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
              ),
            ],
          ),
        ));
      } else {
        return const SplashScreen();
      }
    }));
  }
}
