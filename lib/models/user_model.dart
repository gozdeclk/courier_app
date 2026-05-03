enum UserRole { admin, courier }

class AppUser {
  final String id;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: (map['email'] ?? '') as String,
      role: (map['role'] ?? 'courier') == 'admin'
          ? UserRole.admin
          : UserRole.courier,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'courier',
    };
  }
}