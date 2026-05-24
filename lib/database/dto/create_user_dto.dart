class CreateUserDto {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role; // 'doctor' или 'patient'
  final String? referralCode; // только для patient, для doctor null

  CreateUserDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.referralCode,
  });

  factory CreateUserDto.fromMap(Map<String, dynamic> map) {
    if (map['firstName'] == null ||
        map['lastName'] == null ||
        map['email'] == null ||
        map['password'] == null ||
        map['role'] == null) {
      throw FormatException('Missing required fields');
    }

    return CreateUserDto(
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      referralCode: map['referral_code'] as String?,
    );
  }

  String? validate() {
    if (firstName.isEmpty) return 'Поле имя обязательно';
    if (email.length < 8) return 'Некоректный email';
    if (!email.contains('@')) return 'Некоректный email';
    if (password.length < 6) return 'password too short';
    if (role != 'doctor' && role != 'patient') return 'invalid role';
    if (role == 'patient' && (referralCode == null || referralCode!.isEmpty)) {
      return 'реферальный код обязателен для пациента';
    }
    return null;
  }
}
