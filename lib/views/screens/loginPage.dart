import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/theme.dart';

import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // const LoginPage({super.key});
  // int counter=0;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // int counter = 0;
  final _formKey1 = GlobalKey<FormState>();
  // final GlobalKey<  FlutterPwValidatorState> validatorKey = GlobalKey<FlutterPwValidatorState>();
  late User user;
  final bool _checkboxState = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // user = User();
    super.initState();
  }

  @override
  void dispose() {
    // user = User();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is SignUpFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).add(SignUp());
              },
            ),
          ));
        }
        if (state is LogInFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("login failed"),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ));
        }
      },
      child: Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              // Background gradient
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Logo
                      SizedBox(
                        height: 125,
                        width: 250,
                        child: Image.asset('assets/bmjlogo.png'),
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        "Welcome Back!",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to continue",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Username input
                      _usernameInputBox(),
                      const SizedBox(height: 20),
                      // Password input
                      _passwordInputBox(),
                      const SizedBox(height: 10),
                      // Forgot password button
                      _forgotPasswordButton(),
                      const SizedBox(height: 20),
                      // Login button
                      _LoginBtn(),
                      const SizedBox(height: 20),
                      // Divider
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Colors.white70,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white70,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Continue with mobile button
                      _continueWithMobileButton(),
                      const SizedBox(height: 20),
                      // Social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _googleButton(),
                          const SizedBox(width: 20),
                          // Uncomment if Facebook button is needed
                          // _facebookButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Skip button
                      _skipButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidUsername(String usernameString) {
    return RegExp(
        // r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        r'^[0-9]{10}$').hasMatch(usernameString);
  }

  Widget _usernameInputBox() {
    return Container(
      key: UniqueKey(),
      decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        validator: (input) => input!.isEmpty
            ? "       username can't be empty"
            : isValidUsername(input)
                ? null
                : "      Check your username",
        controller: usernameController,
        maxLength: 10,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Opensans', fontSize: 14),
        decoration: InputDecoration(
          hintStyle: GoogleFonts.cormorant(color: Colors.black, fontSize: 16),
          // border: InputBorder.,
          // contentPadding: const EdgeInsets.only(top: 10),
          prefixIcon: const Icon(Icons.email, color: Colors.black),
          hintText: 'Enter your phone number',
        ),
      ),
    );
  }

  Widget _passwordInputBox() {
    return Container(
      // key: UniqueKey(),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        validator: (value) =>
            value!.isEmpty ? '        password can\'t be empty' : null,
        controller: passwordController,
        obscureText: true,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Opensans', fontSize: 15),
        decoration: InputDecoration(
          hintStyle: GoogleFonts.cormorant(color: Colors.black, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 10.0),
          prefixIcon: const Icon(Icons.vpn_key, color: Colors.black),
          hintText: 'Password',
        ),
      ),
    );
  }

  Widget _forgotPasswordButton() {
    return Container(
      key: UniqueKey(),
      alignment: Alignment.centerRight,
      child: MaterialButton(
          onPressed: () {}, child: Text('Forgot Password', style: Mystyle(10))),
    );
  }

  TextStyle Mystyle(double n) {
    return GoogleFonts.changa(
        textStyle: TextStyle(
            color: Colors.black,
            // fontFamily: 'Opensans',
            fontSize: n,
            fontWeight: FontWeight.bold));
  }

  Widget _rememberMeCheckbox() {
    return Row(
      children: <Widget>[
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.black),
          child: Checkbox(
            value: _checkboxState,
            checkColor: Colors.greenAccent,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                // _checkboxState = value;
              });
            },
          ),
        ),
        // const Text('Remember Me', style: LushTheme.body1)
      ],
    );
  }

  Widget _LoginBtn() {
    return ElevatedButton.icon(
      key: UniqueKey(),
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
        // If the button is pressed, return green, otherwise blue
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFFF8228);
        } else {
          return Colors.black45;
        }
      })),
      icon: const FaIcon(FontAwesomeIcons.arrowRight),
      label: Text(
        'Login',
        style: GoogleFonts.rokkitt(
          textStyle: const TextStyle(
              // fontFamily: 'Opensans',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ),
      onPressed: () => {
        if (_formKey1.currentState!.validate())
          {
            _formKey1.currentState!.save(),
            BlocProvider.of<AuthenticationBloc>(context).add(LogIn(
                usernameController.text,
                passwordController.text,
                _checkboxState)),
          }
      },
    );
  }

  Widget _continueWithMobileButton() {
    return ElevatedButton.icon(
      key: UniqueKey(),
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
        // If the button is pressed, return green, otherwise blue
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFFF8228);
        } else {
          return Colors.black45;
        }
      })),
      icon: const FaIcon(FontAwesomeIcons.mobileScreen),
      label: Text(
        'Continue with Mobile Number',
        style: GoogleFonts.rokkitt(
          textStyle: const TextStyle(
              // fontFamily: 'Opensans',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ),
      onPressed: () => {
        // BlocProvider.of<AuthenticationBloc>(context).add(SignUpStart(User(
        //     userid: '',
        //     name: '',
        //     password: '',
        //     flatOrVillaNumber: '',
        //     phoneNo: ''))),
        Navigator.of(context).pushNamed("/mobileNumberPage")
      },
    );
  }

  Widget _skipButton() {
    return InkWell(
      onTap: () {},
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Skip login ",
            style: TextStyle(color: Colors.white70),
          ),
          Icon(Icons.fast_forward_outlined, color: Colors.white70, size: 34.0),
        ],
      ),
    );
  }

  Widget _googleButton() {
    return FloatingActionButton(
        key: UniqueKey(),
        elevation: 25.0,
        heroTag: const Text("googleBtn"),
        onPressed: () {
          // googleSignIn.login().then((value) async {
          // value?.id != null
          // ? {
          // user.id = value!.id,
          // user.email = value.email,
          // user.firstName = value.displayName!.split(' ')[0],
          // user.lastName = value.displayName!.split(' ')[1],
          // user.phone = "",
          // user.password = "",
          // user.photoUrl = value.photoUrl!,
          // user.password=value.serverAuthCode,
          BlocProvider.of<AuthenticationBloc>(context).add(GoogleSignIn());
          // Navigator.of(context).pushNamed("/home")
          //           navService.pushReplacementNamed("/signUpScreen",
          //               args: SignUpScreenArguments(user))
          //         }
          //       : ScaffoldMessenger.of(context)
          //           .showMaterialBanner(MaterialBanner(
          //           content: const Text("Could not login via Google!"),
          //           actions: [
          //             TextButton(
          //                 onPressed: () {
          //                   ScaffoldMessenger.of(context)
          //                       .clearMaterialBanners();
          //                 },
          //                 child: const Text('Ok!'))
          //           ],
          //         ));
          // });
        },
        backgroundColor: LushTheme.white,
        child: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ));
  }

  // Widget _facebookButton() {
  // return FloatingActionButton(
  //     key: UniqueKey(),
  //     elevation: 25.0,
  //     onPressed: () {
  //       Facebook.login().then((loginResult) => {
  //             if (loginResult.status.toString() == "LoginStatus.success")
  //               {
  //                 Facebook.userdata().then((value) => {
  //                       user.firstName = value["name"],
  //                       user.id = value["id"],
  //                       user.email = value["email"],
  //                       // user.photoUrl = value["picture"]["data"]["url"],
  //                       // user.password = loginResult.accessToken!.token,
  //                       BlocProvider.of<AuthenticationBloc>(context)
  //                           .add(SignInFacebook(user)),
  //                       navService.pushReplacementNamed("/signUpScreen",
  //                           args: SignUpScreenArguments(user))
  //                     })
  //               }
  //             else
  //               ScaffoldMessenger.of(context)
  //                   .showMaterialBanner(MaterialBanner(
  //                 content: const Text("Could not login via facebook!"),
  //                 actions: [
  //                   TextButton(
  //                       onPressed: () {
  //                         ScaffoldMessenger.of(context)
  //                             .clearMaterialBanners();
  //                       },
  //                       child: const Text('Ok!'))
  //                 ],
  //               ))
  //           });
  //     },
  //     backgroundColor: LushTheme.white,
  //     child: const FaIcon(
  //       FontAwesomeIcons.facebook,
  //       color: Colors.blueAccent,
  //     ));
  // }
}
