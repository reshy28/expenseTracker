class UserModel {
  final String name;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.name,
    required this.email,
    this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
