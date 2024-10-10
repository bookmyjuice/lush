import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/theme.dart';
import '../models/User.dart';

class AddressScreen extends StatefulWidget {
  final User user;
  static const routeName = '/addressScreen';

  const AddressScreen({super.key, required this.user});

  @override
  AddressScreenState createState() => AddressScreenState();
}

class AddressScreenState extends State<AddressScreen> {
  // bool _checkboxState = false;
  // late User _user;
  // late final User _user = User();
  String society = "Mapsko Casabella";
  final List<String> societies = [
    "Mapsko Casabella",
    "Mapsko Royal Ville",
    "Mapsko Paradise"
  ];
  String towerOrVilla = "B4";
  final List<String> towersOrVillas = ["A1", "AB1", "AB2", "AB3", "AB4", "B4"];
  String flatOrVillaNumber = "1903";
  final List<String> flatsorVillas = [
    "G001",
    "G002",
    "G003",
    "G004",
    "1001",
    "1002",
    "1003",
    "1004",
    "0201",
    "0202",
    "0203",
    "0204",
    "0301",
    "0302",
    "0303",
    "0304",
    "0401",
    "0402",
    "0403",
    "0404",
    "1903"
  ];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    emailController.text = widget.user.email;
    firstNameController.text = widget.user.firstName;
    lastNameController.text = widget.user.lastName;
    emailController.text = widget.user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<AuthenticationBloc>(context, listen: true),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        if (state is AuthenticationFailure) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      // color: Colors.white,
                      //     image: DecorationImage(
                      //   fit: BoxFit.cover,
                      //   opacity: 125.0,
                      //   image: AssetImage("assets/background2.png"),
                      //   // opacity: 5.0
                      // )
                      color: Colors.amber),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  height: double.infinity,
                  width: double.infinity,
                  // padding: EdgeInsets.only(top: 55),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Container(
                        //     alignment: Alignment.topCenter,
                        //     width: 100,
                        //     padding: const EdgeInsets.only(top: 69),
                        //     child: CircleAvatar(
                        //         backgroundImage:
                        //             NetworkImage(widget.user.photoUrl!),
                        // radius: 50)),
                        const SizedBox(height: 20.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              societySelector(),
                              const SizedBox(height: 30.0),
                              towerOrVillaSelector(),
                              const SizedBox(height: 30.0),
                              flatOrVillaSelector(),
                              const SizedBox(height: 30.0),
                              submitButton()
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
      }),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LushTheme.appbarColor,
          padding: const EdgeInsets.all(10),
        ),
        child: const Text(
          'Done!',
          style: TextStyle(
              fontFamily: 'Opensans',
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
          }
        });
  }

  Widget societySelector() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton(
          icon: const FaIcon(
            FontAwesomeIcons.caretDown,
            size: 25,
          ),
          isExpanded: true,
          value: society,
          items: societies.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              society = newValue!;
            });
          },
        ),
      ),
    );
  }

  towerOrVillaSelector() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton(
          isExpanded: true,
          icon: const Icon(FontAwesomeIcons.caretDown),
          value: towerOrVilla,
          items: towersOrVillas.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              towerOrVilla = newValue!;
            });
          },
        ),
      ),
    );
  }

  flatOrVillaSelector() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton(
          alignment: Alignment.center,
          focusColor: Colors.white,
          // dropdownColor: Colors.amber,

          isExpanded: true,
          icon: const Icon(Icons.home),
          value: flatOrVillaNumber,
          items: flatsorVillas.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              flatOrVillaNumber = newValue!;
            });
          },
        ),
      ),
    );
  }
}
