class User {
  User(
      {required this.id,
      required this.email,
      required this.phone,
      required this.role,
      required this.firstName,
      required this.lastName,
      required this.password,
      required this.address,
      required this.city,
      required this.country,
      required this.extendedAddr,
      required this.extendedAddr2,
      required this.state,
      required this.zip});
  User.blank(
      this.address,
      this.city,
      this.country,
      this.email,
      this.extendedAddr,
      this.extendedAddr2,
      this.firstName,
      this.id,
      this.lastName,
      this.password,
      this.phone,
      this.role,
      this.state,
      this.zip);
  String id;
  String email;
  String phone;
  String role;
  String firstName;
  String lastName;
  String password;
  String address;
  String extendedAddr;
  String extendedAddr2;
  String city;
  String state;
  String country;
  String zip;
  String roles = "user";
  String get getId => id;

  set setId(id_) => id = id_;

  String get getEmail => email;

  set setEmail(email_) => email = email_;

  String get getPhone => phone;

  set setPhone(phone_) => phone = phone_;

  String get getRole => role;

  set setRole(role_) => role = role_;

  String get getFirstName => firstName;

  set setFirstName(firstName_) => firstName = firstName_;

  String get getLastName => lastName;

  set setLastName(lastName_) => lastName = lastName_;

  String get getPassword => password;

  set setPassword(password_) => password = password_;

  String get getAddress => address;

  set setAddress(address_) => address = address_;

  String get getExtendedAddr => extendedAddr;

  set setExtendedAddr(extendedAddr_) => extendedAddr = extendedAddr_;

  String get getExtendedAddr2 => extendedAddr2;

  set setExtendedAddr2(extendedAddr2_) => extendedAddr2 = extendedAddr2_;

  String get getCity => city;

  set setCity(city_) => city = city_;

  String get getState => state;

  set setState(state_) => state = state_;

  String get getCountry => country;

  set setCountry(country_) => country = country_;

  String get getZip => zip;

  set setZip(zip_) => zip = zip_;
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'address': address,
        'extendedAddr': extendedAddr,
        'extendedAddr2': extendedAddr2,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip
      };
}
