class Address {
  String firstName;
  String lastName;
  String phone;
  String addr;
  String extended_addr;
  String extended_addr2;
  String city;
  String state_code;
  String zip;
  bool validation_status;
  String subscription_id;

  Address(
      {required this.firstName,
      required this.lastName,
      required this.phone,
      required this.addr,
      required this.extended_addr,
      required this.extended_addr2,
      required this.city,
      required this.state_code,
      required this.zip,
      required this.validation_status,
      required this.subscription_id});

  String get getFirstName => firstName;

  set setFirstName(String firstName) => this.firstName = firstName;

  String get getLastName => lastName;

  set setLastName(String lastName) => this.lastName = lastName;

  String get getPhone => phone;

  set setPhone(String phone) => this.phone = phone;

  String get getAddr => addr;

  set setAddr(String addr) => this.addr = addr;

  String get extendedaddr => extended_addr;

  set extendedaddr(String value) => extended_addr = value;

  String get extendedaddr2 => extended_addr2;

  set extendedaddr2(String value) => extended_addr2 = value;

  String get getCity => city;

  set setCity(String city) => this.city = city;

  String get statecode => state_code;

  set statecode(String value) => state_code = value;

  String get getZip => zip;

  set setZip(String zip) => this.zip = zip;

  bool get validationstatus => validation_status;

  set validationstatus(bool value) => validation_status = value;

  String get subscriptionid => subscription_id;

  set subscriptionid(String value) => subscription_id = value;
}
