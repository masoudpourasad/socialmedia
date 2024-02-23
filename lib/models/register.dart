class Register {
  String? username;
  String? email;
  String? gender;
  String? country;
  String? password;
  String? passwordConfirmation;
  bool publicEmail = false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = username;
    data['email'] = email;
    data['gender'] = gender;
    data['password'] = password;
    data['password_confirmation'] = passwordConfirmation;
    data['public_email'] = publicEmail;
    data['email'] = email;
    return data;
  }
}
