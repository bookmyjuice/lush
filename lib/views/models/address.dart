class Address {
  String firstName;
  String lastName;
  String phone;
  String addr;
  String extendedAddr;
  String extendedAddr2;
  String city;
  String stateCode;
  String zip;
  bool validationStatus;
  String subscriptionId;

  Address(
      {required this.firstName,
      required this.lastName,
      required this.phone,
      required this.addr,
      required this.extendedAddr,
      required this.extendedAddr2,
      required this.city,
      required this.stateCode,
      required this.zip,
      required this.validationStatus,
      required this.subscriptionId});

  String get getFirstName => firstName;

  set setFirstName(String firstName) => this.firstName = firstName;

  String get getLastName => lastName;

  set setLastName(String lastName) => this.lastName = lastName;

  String get getPhone => phone;

  set setPhone(String phone) => this.phone = phone;

  String get getAddr => addr;

  set setAddr(String addr) => this.addr = addr;

  String get extendedaddr => extendedAddr;

  set extendedaddr(String value) => extendedAddr = value;

  String get extendedaddr2 => extendedAddr2;

  set extendedaddr2(String value) => extendedAddr2 = value;

  String get getCity => city;

  set setCity(String city) => this.city = city;

  String get statecode => stateCode;

  set statecode(String value) => stateCode = value;

  String get getZip => zip;

  set setZip(String zip) => this.zip = zip;

  bool get validationstatus => validationStatus;

  set validationstatus(bool value) => validationStatus = value;

  String get subscriptionid => subscriptionId;

  set subscriptionid(String value) => subscriptionId = value;
}
