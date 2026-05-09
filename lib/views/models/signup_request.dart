
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

  Map<String, dynamic> toJson() {
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