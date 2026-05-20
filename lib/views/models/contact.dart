class Contact {
  String firstName;
  String lastName;
  String email;
  String phone;
  bool enabled;
  bool sendAccountEmail;
  bool sendBillingEmail;

  Contact(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.enabled,
      required this.sendAccountEmail,
      required this.sendBillingEmail});

  String get firstname => firstName;

  set firstname(String value) => firstName = value;

  String get lastname => lastName;

  set lastname(String value) => lastName = value;

  String get getEmail => email;

  set setEmail(String email) => this.email = email;

  String get getPhone => phone;

  set setPhone(String phone) => this.phone = phone;

  bool get getEnabled => enabled;

  set setEnabled(bool enabled) => this.enabled = enabled;

  bool get sendaccountEmail => sendAccountEmail;

  set sendaccountEmail(bool value) => sendAccountEmail = value;

  bool get sendbillingEmail => sendBillingEmail;

  set sendbillingEmail(bool value) => sendBillingEmail = value;
}
