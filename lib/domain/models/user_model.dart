class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromDoc(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
