/// Modelo de usuário da aplicação
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'patient' (elderly user) or 'caregiver' (admin)
  final String pin; // PIN for quick access
  final List<String> linkedUsers; // UIDs of linked users (caregivers linked to patients)
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'patient',
    this.pin = '1234',
    this.linkedUsers = const [],
    DateTime? createdAt,
    DateTime? lastLogin,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  /// Converte para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'pin': pin,
      'linkedUsers': linkedUsers,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  /// Cria UserModel a partir de Map do Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'patient',
      pin: map['pin'] ?? '1234',
      linkedUsers: map['linkedUsers'] != null
          ? List<String>.from(map['linkedUsers'])
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : DateTime.now(),
    );
  }

  /// Copia o objeto com modificações
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    String? pin,
    List<String>? linkedUsers,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      linkedUsers: linkedUsers ?? this.linkedUsers,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  bool get isCaregiver => role == 'caregiver';
  bool get isPatient => role == 'patient';
}

