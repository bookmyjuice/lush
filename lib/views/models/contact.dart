class Contact {
  String first_name;
  String last_name;
  String email;
  String phone;
  bool enabled;
  bool send_account_email;
  bool send_billing_email;

  Contact(
      {required this.first_name,
      required this.last_name,
      required this.email,
      required this.phone,
      required this.enabled,
      required this.send_account_email,
      required this.send_billing_email});

  String get firstname => first_name;

  set firstname(String value) => first_name = value;

  String get lastname => last_name;

  set lastname(String value) => last_name = value;

  String get getEmail => email;

  set setEmail(String email) => this.email = email;

  String get getPhone => phone;

  set setPhone(String phone) => this.phone = phone;

  bool get getEnabled => enabled;

  set setEnabled(bool enabled) => this.enabled = enabled;

  bool get sendaccount_email => send_account_email;

  set sendaccount_email(bool value) => send_account_email = value;

  bool get sendbilling_email => send_billing_email;

  set sendbilling_email(bool value) => send_billing_email = value;
}
