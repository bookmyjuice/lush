class SignupRequest {
  String username;
  String email;
  String password;
  String address;
  String extendedAddr;
  String extendedAddr2;
  String firstName;
  String lastName;
  String city;
  String state;
  String country;
  String zip;
  Set<String> role;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.address,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
    required this.role,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    // snake_case from Chargebee, camelCase fallback for internal API
    final rawRole = json['role'];
    return SignupRequest(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      address: (json['address_line1'] ?? json['address']) as String? ?? '',
      extendedAddr: (json['address_line2'] ?? json['extendedAddr']) as String? ?? '',
      extendedAddr2: (json['address_line3'] ?? json['extendedAddr2']) as String? ?? '',
      firstName: (json['first_name'] ?? json['firstName']) as String? ?? '',
      lastName: (json['last_name'] ?? json['lastName']) as String? ?? '',
      city: json['city'] as String? ?? '',
      state: (json['state_code'] ?? json['state']) as String? ?? '',
      country: json['country'] as String? ?? '',
      zip: (json['zip'] ?? json['pincode']) as String? ?? '',
      role: rawRole != null
          ? (rawRole is List ? Set<String>.from(rawRole.map((e) => e.toString())) : {rawRole.toString()})
          : <String>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // snake_case keys — API convention
      'username': username,
      'email': email,
      'password': password,
      'address_line1': address,
      'address_line2': extendedAddr,
      'address_line3': extendedAddr2,
      'first_name': firstName,
      'last_name': lastName,
      'city': city,
      'state_code': state,
      'country': country,
      'zip': zip,
      'role': role.toList(),
    };
  }

  Map<String, dynamic> toDisplayJson() {
    // camelCase keys — UI/display convention
    return {
      'username': username,
      'email': email,
      'password': password,
      'address': address,
      'extendedAddr': extendedAddr,
      'extendedAddr2': extendedAddr2,
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'state': state,
      'country': country,
      'zip': zip,
      'role': role.toList(),
    };
  }
}