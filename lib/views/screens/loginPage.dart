import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/theme.dart';
import 'package:lush/utils/font_utils.dart';
import 'package:toastification/toastification.dart';
// import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(
      {super.key, required this.toast_message, required this.toast_heading});

  final String toast_message;
  final String toast_heading;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // int counter = 0;
  final _formKey1 = GlobalKey<FormState>();
  // final GlobalKey<  FlutterPwValidatorState> validatorKey = GlobalKey<FlutterPwValidatorState>();
  // late User user;
  final bool _checkboxState = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.toast_heading != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          icon: const Icon(Icons.error),
          closeButton: ToastCloseButton(),
          alignment: Alignment.center,
          title: Text(widget.toast_heading),
          description: Text(widget.toast_message),
          type: ToastificationType.error,
        );
      });
    }
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
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) => (current is LogInFailed ||
            current is SignUpFailed ||
            current is AutoLoginFailed),
        listener: (context, state) async {
          if ((state is LogInFailed) && !_dialogShown) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
              title: Text('Login Failed'),
              description: Text('Please check your credentials and try again.'),
              type: ToastificationType.error,
            );
          }
          if (state is SignUpFailed) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
              title: Text('SignUp Failed!'),
              description: Text('Please try again!'),
              type: ToastificationType.error,
            );
          }
          if (state is AutoLoginFailed) {
            _dialogShown = true;
            toastification.show(
              closeButton: ToastCloseButton(),
              title: Text('AutoLogin Failed!'),
              description: Text('Please Login!'),
              type: ToastificationType.error,
            );
          }
        },
        child: Center(
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
                        style: FontUtils.heading1(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to continue",
                        style: FontUtils.bodyText(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Username input
                      _usernameInputBox(),
                      const SizedBox(height: 20),
                      // Password input
                      _passwordInputBox(),
                      const SizedBox(height: 6),
                      // Forgot password button
                      _forgotPasswordButton(),
                      const SizedBox(height: 20),
                      // Login button
                      _LoginBtn(),
                      // const SizedBox(height: 20),
                      // showStateMessage(),
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
                            padding: EdgeInsets.symmetric(horizontal: 6),
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

      // }
    );
  }

  bool isValidUsername(String usernameString) {
    return RegExp(
        // r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        r'^[0-9]{10}$').hasMatch(usernameString);
  }

  Widget _usernameInputBox() {
    return Container(
      // key: UniqueKey(),
      decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        validator: (input) => input!.isEmpty
            ? "       Please enter phone number!"
            : isValidUsername(input)
                ? null
                : "      Check your phone number!",
        controller: usernameController,
        maxLength: 10,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.phone,
        style: FontUtils.bodyText(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
          hintStyle: FontUtils.hintText(color: Colors.black, fontSize: 16),
          // border: InputBorder.,
          // contentPadding: const EdgeInsets.only(top: 10),
          prefixIcon: const Icon(Icons.phone, color: Colors.black),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              usernameController.clear();
            },
          ),
          hintText: 'Enter 10 digit phone no.',
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
            value!.isEmpty ? '        Please enter password!' : null,
        controller: passwordController,
        obscureText: true,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        style: FontUtils.bodyText(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintStyle: FontUtils.hintText(color: Colors.black, fontSize: 16),
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
          onPressed: () {
            Navigator.of(context).pushNamed("/mobileNumberPage");
          },
          child: Text('Forgot Password', style: Mystyle(10))),
    );
  }

  TextStyle Mystyle(double n) {
    return FontUtils.bodyText(
        color: Colors.black, fontSize: n, fontWeight: FontWeight.bold);
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
        style: FontUtils.buttonText(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
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
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFFF8228);
        } else {
          return Colors.black45;
        }
      })),
      icon: const FaIcon(FontAwesomeIcons.mobileScreen),
      label: Text(
        'Sign Up with Phone Number',
        style: FontUtils.buttonText(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () => {Navigator.of(context).pushNamed("/mobileNumberPage")},
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

          BlocProvider.of<AuthenticationBloc>(context).add(const GoogleSignIn());
        },
        backgroundColor: LushTheme.white,
        child: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ));
  }

  Widget showStateMessage() {
    return Container(
      color: Colors.black45,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is SignUpFailed) {
            return Text("SignUp failed: ${state.error}",
                style: const TextStyle(color: Colors.red));
          } else if (state is LogInFailed) {
            return const Text(
              "Login failed!",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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
