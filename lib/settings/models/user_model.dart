class UserModel {
  final String name;
  final String email;
  final String avatarUrl;

  UserModel({required this.name, required this.email, required this.avatarUrl});

  UserModel copyWith({String? name, String? email, String? avatarUrl}) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
