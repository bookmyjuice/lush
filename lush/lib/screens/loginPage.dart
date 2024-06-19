// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hexcolor/hexcolor.dart';
import 'package:lush/bloc/AuthBloc.dart';
import 'package:lush/events/AuthEvents.dart';
import 'package:lush/main.dart';
import 'package:lush/models/Facebook.dart';
import 'package:lush/models/User.dart';
import 'package:lush/models/googleSignIn.dart';
import 'package:lush/theme.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
// import '../main.dart';
// import '..//models/Facebook.dart';
// import '../models/User.dart';
// import '../models/googleSignIn.dart';

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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    user = User();
    super.initState();
  }

  @override
  void dispose() {
    user = User();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // counter++;
    return BlocProvider.value(
      // key: UniqueKey(),
      value: BlocProvider.of<AuthenticationBloc>(context, listen: true),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 55),
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                    // backgroundBlendMode: BlendMode.hardLight,

                    //     image: DecorationImage(repeat: ImageRepeat.repeat,
                    //   fit: BoxFit.fill,
                    //   image: AssetImage("assets/background2.png"),
                    //   // opacity: 5.0
                    // ) ,
                    // gradient: LinearGradient(
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //     colors: [
                    //       Color(0xFFdae869),
                    //       Color(0xFF988623),
                    //
                    //       // // Color(0xFFFAF3D6),
                    //       // Color(0xFFB8292C),
                    //       // Color(0xFF203D10)
                    //     ]),
                    color: Colors.orange),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 2.0),
                            borderRadius: BorderRadius.circular(20.0)),
                        alignment: Alignment.topCenter,
                        width: 300,
                        // ? 300
                        // : MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 90,
                                  width: 90,
                                  child: Image.asset('assets/lushlogo.png')),
                              const SizedBox(height: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _emailInputBox(),
                                  const SizedBox(height: 20.0),
                                  _passwordInputBox(),
                                  _forgotPasswordButton(),
                                  _rememberMeCheckbox(),
                                  _LoginBtn(),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _continueWithMobileButton(),
                      // const SizedBox(height: 15),
                      ButtonBar(
                        buttonPadding:
                            const EdgeInsets.fromLTRB(25, 10, 25, 10),
                        alignment: MainAxisAlignment.center,
                        children: [
                          _googleButton(),
                          _facebookButton(),
                        ],
                      ),

                      _skipButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  bool isValidEmail(String emailString) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(emailString);
  }

  Widget _emailInputBox() {
    return Container(
      key: UniqueKey(),
      decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        validator: (input) => input!.isEmpty
            ? "       email can't be empty"
            : isValidEmail(input)
                ? null
                : "      Check your email",
        controller: emailController,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Opensans', fontSize: 14),
        decoration: InputDecoration(
          hintStyle: GoogleFonts.cormorant(color: Colors.black, fontSize: 16),
          // border: InputBorder.,
          // contentPadding: const EdgeInsets.only(top: 10),
          prefixIcon: const Icon(Icons.email, color: Colors.black),
          hintText: 'Enter your e-mail',
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
            Navigator.of(context).pushNamed("/home2")
          }
        // BlocProvider.of<AuthenticationBloc>(context).add(SignUpStart(User(
        //     userid: '',
        //     name: '',
        //     password: '',
        //     flatOrVillaNumber: '',
        //     phoneNo: ''))),
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
          googleSignIn.login().then((value) async {
            value?.id != null
                ? {
                    user.userid = value!.id,
                    user.email = value.email,
                    user.name = value.displayName!,
                    user.photoUrl = value.photoUrl!,
                    // user.password=value.serverAuthCode,
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(SignInGoogle(user)),
                    // Navigator.of(context).pushNamed("/home")
                    navService.pushReplacementNamed("/signUpScreen",
                        args: SignUpPageArguments(user))
                  }
                : ScaffoldMessenger.of(context)
                    .showMaterialBanner(MaterialBanner(
                    content: const Text("Could not login via Google!"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: const Text('Ok!'))
                    ],
                  ));
          });
        },
        backgroundColor: LushTheme.white,
        child: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ));
  }

  Widget _facebookButton() {
    return FloatingActionButton(
        key: UniqueKey(),
        elevation: 25.0,
        onPressed: () {
          Facebook.login().then((loginResult) => {
                if (loginResult.status.toString() == "LoginStatus.success")
                  {
                    Facebook.userdata().then((value) => {
                          user.name = value["name"],
                          user.userid = value["id"],
                          user.email = value["email"],
                          user.photoUrl = value["picture"]["data"]["url"],
                          // user.password = loginResult.accessToken!.token,
                          BlocProvider.of<AuthenticationBloc>(context)
                              .add(SignInFacebook(user)),
                          navService.pushReplacementNamed("/signUpScreen",
                              args: SignUpPageArguments(user))
                        })
                  }
                else
                  ScaffoldMessenger.of(context)
                      .showMaterialBanner(MaterialBanner(
                    content: const Text("Could not login via facebook!"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: const Text('Ok!'))
                    ],
                  ))
              });
        },
        backgroundColor: LushTheme.white,
        child: const FaIcon(
          FontAwesomeIcons.facebook,
          color: Colors.blueAccent,
        ));
  }
}
