// Serialization: toJson() uses snake_case (Chargebee convention).
// For UI display use toDisplayJson() (camelCase).
class Contact {
  String firstName;
  String lastName;
  String email;
  String phone;
  bool enabled;
  bool sendAccountEmail;
  bool sendBillingEmail;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.enabled,
    required this.sendAccountEmail,
    required this.sendBillingEmail,
  });

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

  factory Contact.fromJson(Map<String, dynamic> json) {
    // snake_case from Chargebee, camelCase fallback for internal API
    final rawFirstName = json['first_name'] ?? json['firstName'];
    final rawLastName = json['last_name'] ?? json['lastName'];
    final rawEmail = json['email'];
    final rawPhone = json['phone'];
    final rawEnabled = json['enabled'];
    final rawSendAccount = json['send_account_email'] ?? json['sendAccountEmail'];
    final rawSendBilling = json['send_billing_email'] ?? json['sendBillingEmail'];

    return Contact(
      firstName: rawFirstName is String ? rawFirstName : '',
      lastName: rawLastName is String ? rawLastName : '',
      email: rawEmail is String ? rawEmail : '',
      phone: rawPhone is String ? rawPhone : '',
      enabled: rawEnabled is bool ? rawEnabled : false,
      sendAccountEmail: rawSendAccount is bool ? rawSendAccount : false,
      sendBillingEmail: rawSendBilling is bool ? rawSendBilling : false,
    );
  }

  Map<String, dynamic> toJson() => {
    // snake_case keys — Chargebee convention
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'enabled': enabled,
    'send_account_email': sendAccountEmail,
    'send_billing_email': sendBillingEmail,
  };

  Map<String, dynamic> toDisplayJson() => {
    // camelCase keys — UI/display convention
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'enabled': enabled,
    'sendAccountEmail': sendAccountEmail,
    'sendBillingEmail': sendBillingEmail,
  };
}
