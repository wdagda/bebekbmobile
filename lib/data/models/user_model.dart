class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final String fullName;
  final String? fotoPath;
  final String role;
  final bool biometricEnabled;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    this.fotoPath,
    this.role = 'owner',
    this.biometricEnabled = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'],
    username: m['username'],
    passwordHash: m['password_hash'],
    fullName: m['full_name'],
    fotoPath: m['foto_path'],
    role: m['role'] ?? 'owner',
    biometricEnabled: (m['biometric_enabled'] ?? 0) == 1,
    createdAt: m['created_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'password_hash': passwordHash,
    'full_name': fullName,
    'foto_path': fotoPath,
    'role': role,
    'biometric_enabled': biometricEnabled ? 1 : 0,
    'created_at': createdAt,
  };
}
