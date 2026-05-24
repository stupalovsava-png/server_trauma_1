// lib/models/user_role.dart
//SealedClass нужен для четкого разделения на 2 роли doc/pat 2
sealed class UserRole {
  const UserRole();

  // для сохранения в БД
  String get role;

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return switch (map['role'] as String) {
      'doctor' => Doctor(generatedCode: map['generated_code'] as String? ?? ''),
      'patient' => Patient(referralCode: map['referral_code'] as String? ?? ''),
      _ => throw ArgumentError('Unknown role: ${map['role']}'),
    };
  }

  Map<String, dynamic> toMap();
}

class Doctor extends UserRole {
  final String generatedCode;
  const Doctor({required this.generatedCode});

  @override
  String get role => 'doctor';

  @override
  Map<String, dynamic> toMap() => {
    'role': 'doctor',
    'generated_code': generatedCode,
    'referral_code': null,
  };
}

class Patient extends UserRole {
  final String referralCode;
  const Patient({required this.referralCode});

  @override
  String get role => 'patient';

  @override
  Map<String, dynamic> toMap() => {
    'role': 'patient',
    'generated_code': null,
    'referral_code': referralCode,
  };
}
