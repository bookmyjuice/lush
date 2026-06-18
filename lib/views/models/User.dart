class User {
  User({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.address,
    required this.city,
    required this.country,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.state,
    required this.zip,
    this.role = 'user',
    this.referralCode,
  });

  String id;
  String email;
  String phone;
  String role;
  String firstName;
  String lastName;
  String password;
  String address;
  String extendedAddr;
  String extendedAddr2;
  String city;
  String state;
  String country;
  String zip;
  String? referralCode;

  // Blank factory for creating a default empty user
  factory User.blank() => User(
        id: '',
        email: '',
        phone: '',
        firstName: '',
        lastName: '',
        password: '',
        address: '',
        city: '',
        country: '',
        extendedAddr: '',
        extendedAddr2: '',
        state: '',
        zip: '',
        referralCode: null,
      );

  String get getId => id;
  set setId(String id_) => id = id_;

  String get getEmail => email;
  set setEmail(String email_) => email = email_;

  String get getPhone => phone;
  set setPhone(String phone_) => phone = phone_;

  String get getRole => role;
  set setRole(String role_) => role = role_;

  String get getFirstName => firstName;
  set setFirstName(String firstName_) => firstName = firstName_;

  String get getLastName => lastName;
  set setLastName(String lastName_) => lastName = lastName_;

  String get getPassword => password;
  set setPassword(String password_) => password = password_;

  String get getAddress => address;
  set setAddress(String address_) => address = address_;

  String get getExtendedAddr => extendedAddr;
  set setExtendedAddr(String extendedAddr_) => extendedAddr = extendedAddr_;

  String get getExtendedAddr2 => extendedAddr2;
  set setExtendedAddr2(String extendedAddr2_) => extendedAddr2 = extendedAddr2_;

  String get getCity => city;
  set setCity(String city_) => city = city_;

  String get getState => state;
  set setState(String state_) => state = state_;

  String get getCountry => country;
  set setCountry(String country_) => country = country_;

  String get getZip => zip;
  set setZip(String zip_) => zip = zip_;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      firstName: (json['first_name'] ?? json['firstName'] ?? '') as String,
      lastName: (json['last_name'] ?? json['lastName'] ?? '') as String,
      password: (json['password'] ?? '') as String,
      address: (json['address_line1'] ?? json['address'] ?? '') as String,
      extendedAddr: (json['address_line2'] ?? json['extendedAddr'] ?? '') as String,
      extendedAddr2: (json['address_line3'] ?? json['extendedAddr2'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      state: (json['state'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      zip: (json['zip'] ?? json['pincode'] ?? '') as String,
      referralCode: json['referral_code'] as String? ?? json['referralCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'address_line1': address,
        'address_line2': extendedAddr,
        'address_line3': extendedAddr2,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip,
        'referral_code': referralCode,
      };

  Map<String, dynamic> toDisplayJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'address': address,
        'extendedAddr': extendedAddr,
        'extendedAddr2': extendedAddr2,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip,
        'referralCode': referralCode,
      };
}
