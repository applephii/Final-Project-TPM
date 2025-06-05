class UserModel {
  final int id;
  final String username;
  final String email;
  final String? password;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      // password: json['password'] as String? ?? '',
      // photoUrl: json['photo_url'] as String?,
      password: json['password'] ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
  }
}
