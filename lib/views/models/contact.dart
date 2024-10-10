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

  get firstname => first_name;

  set firstname(value) => first_name = value;

  get lastname => last_name;

  set lastname(value) => last_name = value;

  get getEmail => email;

  set setEmail(email) => this.email = email;

  get getPhone => phone;

  set setPhone(phone) => this.phone = phone;

  get getEnabled => enabled;

  set setEnabled(enabled) => this.enabled = enabled;

  get sendaccount_email => send_account_email;

  set sendaccount_email(value) => send_account_email = value;

  get sendbilling_email => send_billing_email;

  set sendbilling_email(value) => send_billing_email = value;
}
