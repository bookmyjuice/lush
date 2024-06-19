import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc.dart';
import 'package:lush/states/AuthenticationState.dart';
import 'package:lush/theme.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

// import '../events/AuthEvents.dart';
import '../main.dart';
import '../models/User.dart';

class SignUpScreen extends StatefulWidget {
  late User user;
  static const routeName = '/signUpScreen';

  SignUpScreen({super.key, required this.user});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  // bool _checkboxState = false;
  // late User _user;
  // late final User _user = User();
  final _formKey2 = GlobalKey<FormState>();
  final GlobalKey<FlutterPwValidatorState> validatorKey =
      GlobalKey<FlutterPwValidatorState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  late bool enableSubmitButton;
  // late String _res;
  // UserRepository _userRepository = UserRepository();
  // late int statusCode;
  @override
  void initState() {
    enableSubmitButton=false;
    if (widget.user.email != null) emailController.text = widget.user.email!;
    if (widget.user.name != null) fullnameController.text = widget.user.name!;
    // if(widget.user.phoneNo!=null) phoneNumberController.text = widget.user.phoneNo!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationFailure) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.topCenter,
                          width: 100,
                          padding: const EdgeInsets.only(top: 69),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.user.photoUrl!),
                            radius: 50,
                          )),
                      const SizedBox(height: 20.0),
                      Form(
                        key: _formKey2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _fullNameInputBox(),
                            const SizedBox(height: 30.0),
                            _emailInputBox(state.user.email!),
                            const SizedBox(height: 30.0),
                            _phoneNumberInoutBox(),
                            const SizedBox(height: 30.0),
                            _passwordInputBox(),
                            const SizedBox(height: 30.0),
                            FlutterPwValidator(
                              key: validatorKey,
                              controller: passwordController,
                              minLength: 8,
                              uppercaseCharCount: 1,
                              numericCharCount: 2,
                              specialCharCount: 1,
                              normalCharCount: 3,
                              width: 400,
                              height: 150,
                              onSuccess: () {
                                print("MATCHED");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Password is good!")));
                                enableSubmitButton=true;
                              },
                              onFail: () {
                                print("Bad Password!");
                              },
                            ),
                            _SignUpBtn()
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      } else {
        return MaterialButton(
            onPressed: () {},
            child: const Text(
              "SignUp state error!",
              style: TextStyle(color: Colors.white),
            ));
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  bool isValidEmail(String emailString) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(emailString);
  }

  bool phoneNumberValidator(String value) {
    return RegExp(
            r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
        .hasMatch(value);
  }

  Widget _emailInputBox(String email) {
    return Container(
      decoration: BoxDecoration(
          color: LushTheme.appbarColor,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        enabled: widget.user.email == null ? true : false,
        // key: _formKey2,
        validator: (input) => input!.isEmpty
            ? "      email can't be empty"
            : isValidEmail(input)
                ? null
                : "      Check your email",
        controller: emailController,
        textAlign: TextAlign.start,
        keyboardAppearance: Brightness.dark,
        // keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Opensans', fontSize: 15),
        decoration: InputDecoration(
          hintStyle: const TextStyle(
              color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
              //fontWeight: FontWeight.bold
              ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 10),
          prefixIcon: const Icon(Icons.email, color: Colors.white),
          hintText: email,
          // labelText: "email"
        ),
      ),
    );
  }

  Widget _passwordInputBox() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        // key: _formKey2,
        // enabled: widget.user.password ==null? true: false,
        controller: passwordController,
        onSaved: (newValue) {
          widget.user.password = newValue;
        },
        // initialValue: widget.user.password ?? '',
        // validator: (value) =>enableSubmitButton.
        // value!.isEmpty ? '    password can\'t be empty' : value!.length<8?'password length should be at least 8': value!.contains(_password),
        obscureText: true,

        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
            //fontWeight: FontWeight.bold
            ),
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
              //fontWeight: FontWeight.bold
              ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Icon(Icons.vpn_key, color: LushTheme.appbarColor),
          hintText: 'Password',
        ),
      ),
    );
  }

  Widget _fullNameInputBox() {
    return Container(
      decoration: BoxDecoration(
          color: LushTheme.appbarColor,
          border: Border.all(),
          borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        // onSaved: (name)=> widget.user.name=name,
        enabled: widget.user.name == null ? true : false,
        validator: (value) =>
            value!.isEmpty ? 'fullName can\'t be empty' : null,
        controller: fullnameController,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        style: const TextStyle(
            color: LushTheme.dark_grey, fontFamily: 'Opensans', fontSize: 15),
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              color: LushTheme.nearlyWhite,
              fontFamily: 'Opensans',
              fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Icon(FontAwesomeIcons.user, color: Colors.white),
          hintText: 'Full Name',
        ),
      ),
    );
  }

  Widget _phoneNumberInoutBox() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
      child: TextFormField(
        // enabled: widget.user.phoneNo!.isEmpty? true:false,
        maxLength: 10,
        // key: _formKey2,
        validator: (input) => input!.isEmpty
            ? "      Phone number can't be empty"
            : phoneNumberValidator(input)
                ? null
                : "      Check your phone number",
        controller: phoneNumberController,
        textAlign: TextAlign.start,
        // initialValue: widget.user.phoneNo,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
            //fontWeight: FontWeight.bold
            ),
        onSaved: (newValue) {
          // widget.user.phoneNo = newValue;
        },
        // onFieldSubmitted: (value) {
        //   // widget.user.phoneNo = value;
        // },
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
              //fontWeight: FontWeight.bold
              ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
          hintText: 'Phone number ..',
        ),
      ),
    );
  }

  TextStyle Mystyle(double n) {
    return TextStyle(
        color: Colors.white,
        fontFamily: 'Opensans',
        fontSize: n,
        fontWeight: FontWeight.bold);
  }

  Widget _SignUpBtn() {
    return enableSubmitButton?ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LushTheme.appbarColor,
          padding: const EdgeInsets.all(10),
        ),
        child: const Text(
          'Continue..',
          style: TextStyle(
              fontFamily: 'Opensans',
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400),
        ),
        onPressed: () {
          if (_formKey2.currentState!.validate()) {
            _formKey2.currentState!.save();
            navService.pushReplacementNamed("/addressScreen",
                args: AddresScreenArguments(widget.user));
          }
        }):ElevatedButton(onPressed: (){}, child: const Text("please fill all details"));
  }
}
