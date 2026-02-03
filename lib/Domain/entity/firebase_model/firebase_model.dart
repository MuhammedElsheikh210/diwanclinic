class FirebaseAuthModel {
  final String email;
  final String password;


  FirebaseAuthModel(this.email, this.password);

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (email.isNotEmpty) data['email'] = email;
    if (password.isNotEmpty) data['password'] = password;
    return data;
  }

  // Create an object from a JSON map
  factory FirebaseAuthModel.fromJson(Map<String, dynamic> json) {
    return FirebaseAuthModel(
      json['email'] as String,
      json['password'] as String,
    );
  }
}
