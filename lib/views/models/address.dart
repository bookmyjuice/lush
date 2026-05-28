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

  String get firstNameGetter => firstName;

  set setFirstName(String firstName) => this.firstName = firstName;

  String get lastNameGetter => lastName;

  set setLastName(String lastName) => this.lastName = lastName;

  String get phoneGetter => phone;

  set setPhone(String phone) => this.phone = phone;

  String get addrGetter => addr;

  set setAddr(String addr) => this.addr = addr;

  String get extendedAddrGetter => extendedAddr;

  set extendedAddrSetter(String value) => extendedAddr = value;

  String get extendedAddr2Getter => extendedAddr2;

  set extendedAddr2Setter(String value) => extendedAddr2 = value;

  String get cityGetter => city;

  set setCity(String city) => this.city = city;

  String get stateCodeGetter => stateCode;

  set stateCodeSetter(String value) => stateCode = value;

  String get zipGetter => zip;

  set setZip(String zip) => this.zip = zip;

  bool get validationStatusGetter => validationStatus;

  set validationStatusSetter(bool value) => validationStatus = value;

  String get subscriptionIdGetter => subscriptionId;

  set subscriptionIdSetter(String value) => subscriptionId = value;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addr: json['addr'] as String? ?? '',
      extendedAddr: json['extendedAddr'] as String? ?? '',
      extendedAddr2: json['extendedAddr2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      stateCode: json['stateCode'] as String? ?? '',
      zip: json['zip'] as String? ?? '',
      validationStatus: json['validationStatus'] as bool? ?? false,
      subscriptionId: json['subscriptionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'addr': addr,
        'extendedAddr': extendedAddr,
        'extendedAddr2': extendedAddr2,
        'city': city,
        'stateCode': stateCode,
        'zip': zip,
        'validationStatus': validationStatus,
        'subscriptionId': subscriptionId,
      };

  String get formatted {
    final parts = <String>[
      addr,
      extendedAddr,
      extendedAddr2,
      city,
      stateCode,
      zip,
    ].where((p) => p.isNotEmpty);
    return parts.join(', ');
  }
}
