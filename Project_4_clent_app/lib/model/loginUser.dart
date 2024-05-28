class LoginUser {
  String? email;
  String? password;

  LoginUser({this.email, this.password});

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      email: json['Email'],
      password: json['Password'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Email'] = email;
    data['Password'] = password;
    return data;
  }
}
