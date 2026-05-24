import 'package:server_trauma_1/database/models/role_model.dart';
import 'package:server_trauma_1/database/models/user_model.dart';

///passwordHash сюда никогда не попадает — клиент не должен его видеть
///fromUser() использует pattern matching чтобы вытащить поле нужной роли
///toMap() отдаёт null для неиспользуемого поля — клиент сам разберётся
class UserResponseDto {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? generatedCode; // только для doctor
  final String? referralCode; // только для patient

  UserResponseDto({
    required this.id,
    required this.firstName,
    required this.email,
    required this.role,
    this.generatedCode,
    this.referralCode,
    required this.lastName,
  });
  factory UserResponseDto.fromUser(User user) {
    return UserResponseDto(
      id: user.id!,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      role: user.role.role,
      generatedCode: switch (user.role) {
        Doctor d => d.generatedCode,
        Patient _ => null,
      },
      referralCode: switch (user.role) {
        Patient p => p.referralCode,
        Doctor _ => null,
      },
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
    'generated_code': generatedCode,
    'referral_code': referralCode,
  };
}
