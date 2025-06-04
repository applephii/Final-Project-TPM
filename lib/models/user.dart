class UserModel {
  final int id;
  final String username;
  final String email;
  final String? password;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.password
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
    };
  }
}
