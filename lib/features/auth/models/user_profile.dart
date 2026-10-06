class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photo,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'client' ou 'driver'
  final String? photo;

  bool get isDriver => role == 'driver';

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'client',
      photo: map['photo'] as String?,
    );
  }
}
