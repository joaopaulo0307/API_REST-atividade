class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Tenta diferentes formatos de campos
    final id = json['id'] ?? json['_id'] ?? '1';
    final name = json['name'] ?? json['username'] ?? 'Usuário';
    final email = json['email'] ?? 'email@example.com';
    final role = json['role'] ?? json['type'] ?? 'USER';

    return User(
      id: id.toString(),
      name: name.toString(),
      email: email.toString(),
      role: role.toString().toUpperCase(),
    );
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isUser => role == 'USER';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}