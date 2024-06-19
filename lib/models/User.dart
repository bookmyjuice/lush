class User {
  late final String? userid;
  late final String? name;
  late final String? password;
  late final String? flatOrVillaNumber;
  late final String? phoneNo;
  late final String? email;
  late final String? photoUrl;
  User();
  User googleDetails (String name, String email, String photoUrl){
    this.name=name;
    this.email=email;
    this.photoUrl;
    return this;
  }

}
