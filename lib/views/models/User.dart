class User {
  User(
      {required this.id,
      required this.email,
      required this.phone,
      required this.role,
      required this.firstName,
      required this.lastName,
      required this.password});

  // late User(String id);
  // Contact contact;
  // Address address;
  String id;
  String email;
  String phone;
  String role;
  String firstName;
  String lastName;
  String password;

  // User({required this.contact, required this.address});

  // User googleDetails(String name, String email, String photoUrl) {
  //   this.contact.first_name = name;
  //   this.contact.email = email;
  //   this.photoUrl;
  //   return this;
  // }
}
