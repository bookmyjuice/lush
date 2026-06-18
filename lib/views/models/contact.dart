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

  // Direct field access via dart getters/setters is preferred.
  // Redundant getters/setters have been removed to eliminate
  // inconsistent casing (e.g. sendaccountEmail vs sendAccountEmail).

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
