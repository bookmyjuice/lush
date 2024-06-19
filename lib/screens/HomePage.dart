import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc.dart';
import 'package:lush/screens/HomePage2.dart';

// import 'package:lush/screens/SignUpScreen.dart';
import '../events/AuthEvents.dart';
import '../models/User.dart';
import '../states/AuthenticationState.dart';

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
      if (state is AuthenticationSuccess) {
        return const HomePage2();
      } else if (state is AuthenticationFailure) {
        return SafeArea(
            child: Center(
                child: ElevatedButton(
          onPressed: () {},
          child: Text("Auth Failure for ${state.user.email}"),
        )));
      } else {
        return SafeArea(
            child: Center(
                child: FilledButton(
          onPressed: () {
            User user = User();
            context
                .read<AuthenticationBloc>()
                .add(AuthenticationFailed(user: user));
          },
          child: const Text("else button"),
        )));
      }
    }));
  }
}
