import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/UserRepository/userRepository.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/getIt.dart';
// import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
// import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/theme.dart';

class AddressScreen extends StatefulWidget {
  // final User user;
  // address: address, extendedAddr: extendedAddr, extendedAddr2: extendedAddr2, city: city, state: state, country: country, zip: zip
  // final String address;
  // final String extendedAddr;
  // final String extendedAddr2;
  // final String city;
  // final String state;
  // final String country;
  // final String zip;

  static const routeName = '/addressScreen';

  const AddressScreen({super.key});

  // const AddressScreen();

  @override
  AddressScreenState createState() => AddressScreenState();
}

class AddressScreenState extends State<AddressScreen> {
  AddressScreenState();
  // bool _checkboxState = false;
  // late User _user;
  // late final User _user = User();
  // final String email;
  // final String fname;
  // final String lname;
  // final String phone;
  // String society = "Mapsko Casabella";
  // final List<String> societies = [
  //   "Mapsko Casabella",
  //   "Mapsko Royal Ville",
  //   "Mapsko Paradise"
  // ];
  // String towerOrVilla = "B4";
  // final List<String> towersOrVillas = ["A1", "AB1", "AB2", "AB3", "AB4", "B4"];
  // String flatOrVillaNumber = "1903";
  // final List<String> flatsorVillas = [
  //   "G001",
  //   "G002",
  //   "G003",
  //   "G004",
  //   "1001",
  //   "1002",
  //   "1003",
  //   "1004",
  //   "0201",
  //   "0202",
  //   "0203",
  //   "0204",
  //   "0301",
  //   "0302",
  //   "0303",
  //   "0304",
  //   "0401",
  //   "0402",
  //   "0403",
  //   "0404",
  //   "1903"
  // ];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController extAddressController = TextEditingController();
  final TextEditingController extAddress2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final UserRepository userRepository = getIt.get();

  @override
  void initState() {
    // emailController.text = widget.email;
    // firstNameController.text = widget.fname;
    // lastNameController.text = widget.lname;
    // // emailController.text = widget.email;
    // phoneNumberController.text = widget.phone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        Text("User Id: ${userRepository.user.id}"),
                        const SizedBox(height: 30.0),
                        address(),
                        const SizedBox(height: 30.0),
                        extendedAddress(),
                        const SizedBox(height: 30.0),
                        extendedAddress2(),
                        const SizedBox(height: 30.0),
                        zip()
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
            BlocProvider.of<AuthenticationBloc>(context).add(SignUp(
                address: addressController.text,
                extendedAddr: extAddressController.text,
                extendedAddr2: extAddress2Controller.text,
                city: "Gurugram",
                state: "Haryana",
                country: "IN",
                zip: zipController.text));
          }
        });
  }

  Widget address() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
      child: TextFormField(
        maxLength: 15,
        validator: (input) => (input!.isEmpty) ? "Enter House/flat No." : "",
        controller: addressController,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.streetAddress,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
        onSaved: (newValue) {
          addressController.text = newValue!;
        },
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              color: LushTheme.appbarColor, fontFamily: 'Opensans', fontSize: 15
              //fontWeight: FontWeight.bold
              ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Icon(Icons.home, color: LushTheme.appbarColor),
          hintText: 'House/flat No.',
        ),
      ),
    );
  }

  extendedAddress() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
      child: TextFormField(
        maxLength: 50,

        // key: _formKey2,
        validator: (input) => (input!.isEmpty) ? "Enter sector/locality.." : "",
        controller: extAddressController,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.streetAddress,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
        onSaved: (newValue) {
          extAddressController.text = newValue!;
        },

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

  extendedAddress2() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
      child: TextFormField(
        maxLength: 20,
        validator: (input) => (input!.isEmpty) ? "Enter sector/locality.." : "",
        controller: extAddress2Controller,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.streetAddress,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15),
        onSaved: (newValue) {
          extAddress2Controller.text = newValue!;
        },
        decoration: const InputDecoration(
          hintStyle: TextStyle(
              color: LushTheme.appbarColor,
              fontFamily: 'Opensans',
              fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10.0),
          prefixIcon: Icon(Icons.phone, color: LushTheme.appbarColor),
          hintText: 'Phone number ..',
        ),
      ),
    );
  }

  zip() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
      child: TextFormField(
        // initialValue: phone,
        // enabled: widget.user.phoneNo!.isEmpty? true:false,
        maxLength: 6,
        // key: _formKey2,
        validator: (input) => (input!.isEmpty) ? "Enter zip code" : "",
        // : phoneNumberValidator(input)
        //     ? null
        //     : "      Check your phone number",
        controller: zipController,
        textAlign: TextAlign.start,
        // initialValue: widget.user.phoneNo,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontFamily: 'Opensans', fontSize: 15
            //fontWeight: FontWeight.bold
            ),
        onSaved: (newValue) {
          zipController.text = newValue!;
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
  // flatOrVillaSelector() {
  //   return Container(
  //     color: Colors.white,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: DropdownButton(
  //         key: Key("flat"),
  //         alignment: Alignment.center,
  //         focusColor: Colors.white,
  //         // dropdownColor: Colors.amber,

  //         isExpanded: true,
  //         icon: const Icon(Icons.home),
  //         value: flatOrVillaNumber,
  //         items: flatsorVillas.map((String items) {
  //           return DropdownMenuItem(
  //             value: items,
  //             child: Text(items),
  //           );
  //         }).toList(),
  //         onChanged: (String? newValue) {
  //           setState(() {
  //             flatOrVillaNumber = newValue!;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }
}
