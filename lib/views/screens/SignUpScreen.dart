import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/UserRepository/userRepository.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/getIt.dart';
import 'package:toastification/toastification.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';

  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final UserRepository userRepository = getIt.get();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FlutterPwValidatorState> validatorKey =
      GlobalKey<FlutterPwValidatorState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController extAddress2Controller = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController extAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  bool enableSubmitButton = false;

  @override
  void initState() {
    super.initState();
    emailController.text = userRepository.user.email;
    phoneNumberController.text = userRepository.user.phone;
    firstNameController.text = userRepository.user.firstName;
    lastNameController.text = userRepository.user.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is SignUpStarted) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Sign Up"),
              backgroundColor: Colors.amber,
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fill in the details below to get started.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: firstNameController,
                                label: "First Name",
                                icon: FontAwesomeIcons.user,
                                validator: (value) => value!.isEmpty
                                    ? "First name is required"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: lastNameController,
                                label: "Last Name",
                                icon: FontAwesomeIcons.user,
                                validator: (value) => value!.isEmpty
                                    ? "Last name is required"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value!.isEmpty
                                    ? "Email is required"
                                    : isValidEmail(value)
                                        ? null
                                        : "Enter a valid email",
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: phoneNumberController,
                                label: "Phone Number",
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty
                                    ? "Phone number is required"
                                    : phoneNumberValidator(value)
                                        ? null
                                        : "Enter a valid phone number",
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(),
                              const SizedBox(height: 16),
                              FlutterPwValidator(
                                key: validatorKey,
                                controller: passwordController,
                                minLength: 8,
                                uppercaseCharCount: 1,
                                numericCharCount: 2,
                                specialCharCount: 1,
                                normalCharCount: 3,
                                width: 300,
                                height: 160,
                                onSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Password is strong!"),
                                    ),
                                  );
                                  setState(() {
                                    enableSubmitButton = true;
                                  });
                                },
                                onFail: () {
                                  setState(() {
                                    enableSubmitButton = false;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildConfirmPasswordField(),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: addressController,
                                label: "Flat/House No.",
                                icon: Icons.home,
                                validator: (value) => value!.isEmpty
                                    ? "Address is required"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: extAddressController,
                                label: "Society/Locality",
                                icon: Icons.home,
                                validator: (value) => value!.isEmpty
                                    ? "Society/Locality is required"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: extAddress2Controller,
                                label: "Sector/Area",
                                icon: Icons.home,
                                validator: (value) => value!.isEmpty
                                    ? "Sector/Area is required"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: cityController,
                                label: "City",
                                icon: Icons.location_city,
                                validator: (value) =>
                                    value!.isEmpty ? "City is required" : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                
                                controller: zipController,
                                label: "Zip Code",
                                icon: Icons.pin_drop,
                                
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty
                                    ? "Zip code is required"
                                    : null,
                                    inputFormatters: [LengthLimitingTextInputFormatter(6)]
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: enableSubmitButton
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  if (passwordController.text !=
                                      confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Passwords do not match! Please try again."),
                                      ),
                                    );
                                    return;
                                  } else {
                                    userRepository.user.setFirstName =
                                        firstNameController.text;
                                    userRepository.user.setLastName =
                                        lastNameController.text;
                                    userRepository.user.setPassword =
                                        passwordController.text;
                                    userRepository.user.setEmail =
                                        emailController.text;
                                    userRepository.user.setPhone =
                                        phoneNumberController.text;
                                    userRepository.user.setAddress =
                                        addressController.text;
                                    userRepository.user.setExtendedAddr =
                                        extAddressController.text;
                                    userRepository.user.setExtendedAddr2 =
                                        extAddress2Controller.text;
                                    userRepository.user.setCity =
                                        cityController.text;
                                    userRepository.user.setState =
                                        stateController.text;
                                    userRepository.user.setZip =
                                        addressController.text;
                                    BlocProvider.of<AuthenticationBloc>(context)
                                        .add(SignUp());
                                  }
                                }
                              }
                            : null,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          toastification.show(
            title: Text(state.props.first.toString()),
            autoCloseDuration: const Duration(seconds: 5),
          );
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly:
          controller.text.isNotEmpty, // Make field read-only if pre-filled
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Password is required" : null,
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool phoneNumberValidator(String value) {
    return RegExp(r'^\d{10}$').hasMatch(value);
  }

// Add this widget for the confirm password field
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Confirm Password",
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please confirm your password";
        } else if (value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

// Add this validation logic in the ElevatedButton's onPressed callback

  // Proceed with the signup logic
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_pw_validator/flutter_pw_validator.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lush/UserRepository/userRepository.dart';
// import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
// import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
// import 'package:lush/bloc/AuthBloc/AuthState.dart';
// import 'package:lush/getIt.dart';
// import 'package:lush/theme.dart';
// import 'package:toastification/toastification.dart';
// // import 'package:lush/views/models/User.dart';
// // import 'package:no_context_navigation/no_context_navigation.dart';

// // import '../events/AuthEvents.dart';
// // import '../../main.dart';
// // import '../models/User.dart';

// class SignUpScreen extends StatefulWidget {
//   static const routeName = '/signUpScreen';

//   const SignUpScreen({super.key});

//   // String password = "";

//   @override
//   SignUpScreenState createState() => SignUpScreenState();
// }

// class SignUpScreenState extends State<SignUpScreen> {
//   final UserRepository userRepository = getIt.get();
//   final _formKey2 = GlobalKey<FormState>();
//   final GlobalKey<FlutterPwValidatorState> validatorKey =
//       GlobalKey<FlutterPwValidatorState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController extAddressController = TextEditingController();
//   final TextEditingController extAddress2Controller = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController stateController = TextEditingController();
//   final TextEditingController zipController = TextEditingController();

//   bool enableSubmitButton = false;
//   // late String _res;
//   // UserRepository _userRepository = UserRepository();
//   // late int statusCode;
//   @override
//   void initState() {
//     emailController.text = userRepository.user.email;
//     phoneNumberController.text = userRepository.user.phone;
//     passwordController.text = userRepository.user.password;
//     firstNameController.text = userRepository.user.firstName;
//     lastNameController.text = userRepository.user.lastName;
//     // enableSubmitButton = false;
//     // emailController.text = widget.user.email;
//     // if (widget.user.name != null) fullnameController.text = widget.user.name!;
//     // if(widget.user.phoneNo!=null) phoneNumberController.text = widget.user.phoneNo!;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthenticationBloc, AuthenticationState>(
//         builder: (context, state) {
//       if (state is SignUpStarted) {
//         return Scaffold(
//           body: SafeArea(
//             child: Stack(
//               children: <Widget>[
//                 Container(
//                   height: double.infinity,
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.amber,
//                   ),
//                 ),
//                 Container(
//                   alignment: Alignment.topCenter,
//                   height: double.infinity,
//                   width: double.infinity,
//                   child: SingleChildScrollView(
//                     // hitTestBehavior: ,
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 1, vertical: 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         // Container(
//                         //     alignment: Alignment.topCenter,
//                         //     width: 100,
//                         //     padding: const EdgeInsets.only(top: 69),
//                         //     child: CircleAvatar(
//                         //       backgroundImage:
//                         //           NetworkImage(widget.user.photoUrl!),
//                         //       radius: 50,
//                         //     )),
//                         const SizedBox(height: 20.0),
//                         Form(
//                           key: _formKey2,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: <Widget>[
//                               _fNameInputBox(userRepository.user.firstName),
//                               const SizedBox(height: 30.0),
//                               _lNameInputBox(userRepository.user.lastName),
//                               const SizedBox(height: 30.0),
//                               _emailInputBox(userRepository.user.email),
//                               const SizedBox(height: 30.0),
//                               _phoneNumberInputBox(userRepository.user.phone),
//                               const SizedBox(height: 30.0),
//                               _passwordInputBox(),
//                               FlutterPwValidator(
//                                 key: validatorKey,
//                                 controller: passwordController,
//                                 minLength: 8,
//                                 uppercaseCharCount: 1,
//                                 numericCharCount: 2,
//                                 specialCharCount: 1,
//                                 normalCharCount: 3,
//                                 width: 300,
//                                 height: 167,
//                                 onSuccess: () {
//                                   // print("MATCHED");
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text("Password is good!")));
//                                   setState(() {
//                                     enableSubmitButton = true;
//                                   });
//                                 },
//                                 onFail: () {
//                                   // print("Bad Password!");
//                                   // ScaffoldMessenger.of(context).showSnackBar(
//                                   //     const SnackBar(
//                                   //         content: Text("Bad password!")));
//                                   // enableSubmitButton = true;
//                                 },
//                               ),
//                               const SizedBox(height: 39.0),
//                               address(),
//                               const SizedBox(height: 30.0),
//                               extendedAddress(),
//                               const SizedBox(height: 30.0),
//                               extendedAddress2(),
//                               const SizedBox(height: 30.0),
//                               city(),
//                               const SizedBox(height: 30.0),
//                               zip()
//                               // const SizedBox(height: 30.0),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 65.0),
//                         _SignUpBtn()
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ), // This trailing comma makes auto-formatting nicer for build methods.
//         );
//       } else {
//         toastification.show(
//           title: Text(state.props.first.toString()),
//           autoCloseDuration: const Duration(seconds: 5),
//         );
//         return Center(child: Center());
//       }
//     });
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     phoneNumberController.dispose();
//     super.dispose();
//   }

//   bool isValidEmail(String emailString) {
//     return RegExp(
//             r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
//         .hasMatch(emailString);
//   }

//   bool phoneNumberValidator(String value) {
//     return RegExp(
//             r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
//         .hasMatch(value);
//   }

//   Widget _emailInputBox(String email) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(20)),
//       child: TextFormField(
//         readOnly: email != "",
//         enabled: email == "" ? true : false,
//         // key: _formKey2,
//         validator: (input) => input!.isEmpty
//             ? "      email can't be empty"
//             : isValidEmail(input)
//                 ? null
//                 : "      Check your email",
//         controller: emailController,
//         textAlign: TextAlign.start,
//         keyboardAppearance: Brightness.dark,
//         style: const TextStyle(
//             color: Colors.black, fontFamily: 'Opensans', fontSize: 15),
//         decoration: InputDecoration(
//           hintStyle: const TextStyle(
//               color: LushTheme.appbarColor,
//               fontFamily: 'Opensans',
//               fontSize: 15),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.only(top: 10),
//           prefixIcon: const Icon(Icons.email, color: Colors.white),
//           hintText: email,
//         ),
//       ),
//     );
//   }

//   Widget _passwordInputBox() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(20)),
//       child: TextFormField(
//         // readOnly: pwd!="",
//         onSaved: (pwd) {
//           passwordController.text = pwd!;
//         },
//         controller: passwordController,
//         obscureText: true,

//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.text,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
//             //fontWeight: FontWeight.bold
//             ),
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.vpn_key, color: LushTheme.appbarColor),
//           hintText: 'Password',
//         ),
//       ),
//     );
//   }

//   Widget _fNameInputBox(String fname) {
//     return Container(
//       decoration: BoxDecoration(
//           color: LushTheme.background,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(20)),
//       child: TextFormField(
//         // initialValue: fname,
//         readOnly: fname != "",
//         onSaved: (name) => firstNameController.text = name!,
//         enabled: true,
//         validator: (value) => value!.isEmpty ? 'Name can\'t be empty' : null,
//         controller: firstNameController,
//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.text,
//         style: const TextStyle(
//             color: LushTheme.dark_grey, fontFamily: 'Opensans', fontSize: 15),
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.nearlyWhite,
//               fontFamily: 'Opensans',
//               fontSize: 15),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(FontAwesomeIcons.user, color: Colors.white),
//           hintText: 'Full Name',
//         ),
//       ),
//     );
//   }

//   Widget _lNameInputBox(String lname) {
//     return Container(
//       decoration: BoxDecoration(
//           color: LushTheme.background,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(20)),
//       child: TextFormField(
//         readOnly: lname != "",
//         onSaved: (name) => lastNameController.text = name!,
//         enabled: true,
//         validator: (value) => value!.isEmpty ? 'Surname can\'t be empty' : null,
//         controller: lastNameController,
//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.text,
//         style: const TextStyle(
//             color: LushTheme.dark_grey, fontFamily: 'Opensans', fontSize: 15),
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.nearlyWhite,
//               fontFamily: 'Opensans',
//               fontSize: 15),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(FontAwesomeIcons.user, color: Colors.white),
//           hintText: 'Last Name',
//         ),
//       ),
//     );
//   }

//   Widget _phoneNumberInputBox(String phone) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         readOnly: phone != "",
//         maxLength: 10,
//         key: _formKey2,
//         validator: (input) => input!.isEmpty
//             ? "      Phone number can't be empty"
//             : phoneNumberValidator(input)
//                 ? null
//                 : "      Check your phone number",
//         controller: phoneNumberController,
//         textAlign: TextAlign.start,
//         // initialValue: widget.user.phoneNo,
//         keyboardType: TextInputType.number,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
//             //fontWeight: FontWeight.bold
//             ),
//         onSaved: (newValue) {
//           phoneNumberController.text = newValue!;
//         },
//         // onFieldSubmitted: (value) {
//         //   // widget.user.phoneNo = value;
//         // },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'Phone number ..',
//         ),
//       ),
//     );
//   }

//   Widget address() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         maxLength: 15,
//         validator: (input) => (input!.isEmpty) ? "Enter House/flat No." : "",
//         controller: addressController,
//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.streetAddress,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
//         onSaved: (newValue) {
//           addressController.text = newValue!;
//         },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.home, color: LushTheme.appbarColor),
//           hintText: 'House/flat No.',
//         ),
//       ),
//     );
//   }

//   Widget extendedAddress() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         maxLength: 50,

//         // key: _formKey2,
//         validator: (input) => (input!.isEmpty) ? "Enter sector/locality.." : "",
//         controller: extAddressController,
//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.streetAddress,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
//         onSaved: (newValue) {
//           extAddressController.text = newValue!;
//         },

//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'Address extended ..',
//         ),
//       ),
//     );
//   }

//   Widget extendedAddress2() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         maxLength: 20,
//         validator: (input) => (input!.isEmpty) ? "Enter sector/locality.." : "",
//         controller: extAddress2Controller,
//         textAlign: TextAlign.start,
//         keyboardType: TextInputType.streetAddress,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
//         onSaved: (newValue) {
//           extAddress2Controller.text = newValue!;
//         },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor,
//               fontFamily: 'Opensans',
//               fontSize: 15),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'Address extended..',
//         ),
//       ),
//     );
//   }

//   Widget zip() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         // initialValue: phone,
//         // enabled: widget.user.phoneNo!.isEmpty? true:false,
//         maxLength: 6,
//         // key: _formKey2,
//         validator: (input) => (input!.isEmpty) ? "Enter zip code" : "",
//         // : phoneNumberValidator(input)
//         //     ? null
//         //     : "      Check your phone number",
//         controller: zipController,
//         textAlign: TextAlign.start,
//         // initialValue: widget.user.phoneNo,
//         keyboardType: TextInputType.number,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
//             //fontWeight: FontWeight.bold
//             ),
//         onSaved: (newValue) {
//           zipController.text = newValue!;
//         },
//         // onFieldSubmitted: (value) {
//         //   // widget.user.phoneNo = value;
//         // },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'Zip code',
//         ),
//       ),
//     );
//   }

//   city() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         // initialValue: phone,
//         // enabled: widget.user.phoneNo!.isEmpty? true:false,
//         maxLength: 6,
//         // key: _formKey2,
//         validator: (input) => (input!.isEmpty) ? "Enter city name" : "",
//         // : phoneNumberValidator(input)
//         //     ? null
//         //     : "      Check your phone number",
//         controller: cityController,
//         textAlign: TextAlign.start,
//         // initialValue: widget.user.phoneNo,
//         keyboardType: TextInputType.streetAddress,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
//             //fontWeight: FontWeight.bold
//             ),
//         onSaved: (newValue) {
//           cityController.text = newValue!;
//         },
//         // onFieldSubmitted: (value) {
//         //   // widget.user.phoneNo = value;
//         // },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'City',
//         ),
//       ),
//     );
//   }

//   Widget state() {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(5)),
//       child: TextFormField(
//         // initialValue: phone,
//         // enabled: widget.user.phoneNo!.isEmpty? true:false,
//         maxLength: 6,
//         // key: _formKey2,
//         validator: (input) => (input!.isEmpty) ? "Enter state name" : "",
//         // : phoneNumberValidator(input)
//         //     ? null
//         //     : "      Check your phone number",
//         controller: cityController,
//         textAlign: TextAlign.start,
//         // initialValue: widget.user.phoneNo,
//         keyboardType: TextInputType.text,
//         style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
//             //fontWeight: FontWeight.bold
//             ),
//         onSaved: (newValue) {
//           cityController.text = newValue!;
//         },
//         // onFieldSubmitted: (value) {
//         //   // widget.user.phoneNo = value;
//         // },
//         decoration: const InputDecoration(
//           hintStyle: TextStyle(
//               color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
//               //fontWeight: FontWeight.bold
//               ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.only(top: 10.0),
//           prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
//           hintText: 'State',
//         ),
//       ),
//     );
//   }

//   TextStyle Mystyle(double n) {
//     return TextStyle(
//         color: Colors.white,
//         fontFamily: 'Opensans',
//         fontSize: n,
//         fontWeight: FontWeight.bold);
//   }

//   Widget _SignUpBtn() {
//     return enableSubmitButton
//         ? ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: LushTheme.appbarColor,
//               padding: const EdgeInsets.all(10),
//             ),
//             child: const Text(
//               'Continue..',
//               style: TextStyle(
//                   fontFamily: 'Opensans',
//                   color: Colors.black,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w400),
//             ),
//             onPressed: () {
//               if (_formKey2.currentState!.validate()) {
//                 // _formKey2.currentState!.save();
//                 userRepository.user.setFirstName = firstNameController.text;
//                 userRepository.user.setLastName = lastNameController.text;
//                 userRepository.user.setPassword = passwordController.text;
//                 userRepository.user.setEmail = emailController.text;
//                 userRepository.user.setPhone = phoneNumberController.text;
//                 userRepository.user.setAddress = addressController.text;
//                 userRepository.user.setExtendedAddr = extAddressController.text;
//                 userRepository.user.setExtendedAddr2 =
//                     extAddress2Controller.text;
//                 userRepository.user.setCity = cityController.text;
//                 userRepository.user.setState = stateController.text;
//                 userRepository.user.setZip = addressController.text;
//                 BlocProvider.of<AuthenticationBloc>(context).add(SignUp());
//                 // navService.pushNamed("/addressScreen");
//               }
//             })
//         : TextButton(
//             onPressed: () {}, child: const Text("please fill all details"));
//   }
// }
