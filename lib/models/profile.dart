// profile.dart
class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'],
    phone: json['phone'],
    role: json['role'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
  };
}
