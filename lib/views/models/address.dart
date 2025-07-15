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

  set setFirstName(firstName) => this.firstName = firstName;

  String get getLastName => lastName;

  set setLastName(lastName) => this.lastName = lastName;

  String get getPhone => phone;

  set setPhone(phone) => this.phone = phone;

  String get getAddr => addr;

  set setAddr(addr) => this.addr = addr;

  String get extendedaddr => extended_addr;

  set extendedaddr(value) => extended_addr = value;

  String get extendedaddr2 => extended_addr2;

  set extendedaddr2(value) => extended_addr2 = value;

  String get getCity => city;

  set setCity(city) => this.city = city;

  String get statecode => state_code;

  set statecode(value) => state_code = value;

  String get getZip => zip;

  set setZip(zip) => this.zip = zip;

  bool get validationstatus => validation_status;

  set validationstatus(value) => validation_status = value;

  String get subscriptionid => subscription_id;

  set subscriptionid(value) => subscription_id = value;
}
