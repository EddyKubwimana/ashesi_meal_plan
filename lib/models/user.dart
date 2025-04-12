//  user class 
class User {
  final String? id;
  final String username;
  final String userId;
  final String password;

  User({
    this.id,
    required this.username,
    required this.userId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'userId': userId,
        'password': password,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        userId: json['userId'],
        password: json['password'],
      );
}
