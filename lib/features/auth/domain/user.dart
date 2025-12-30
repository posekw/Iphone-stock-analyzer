class User {
  final String id;
  final String username;
  final String email;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['user_email'] ?? '',
      token: token,
    );
  }
}
