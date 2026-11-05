enum UserRole { student, staff }

class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.hideNameByDefault = false,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  bool hideNameByDefault;

  bool get isStaff => role == UserRole.staff;

  // "Nawaf Ahmed" -> "NA"
  String get initials => name
      .trim()
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join()
      .toUpperCase();

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role.name,
    'hideNameByDefault': hideNameByDefault,
  };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] == 'staff' ? UserRole.staff : UserRole.student,
    hideNameByDefault: map['hideNameByDefault'] ?? false,
  );
}
