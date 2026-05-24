// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:server_trauma_1/database/models/role_model.dart';

// Создаем модель юзера
class User {
  final int?
  id; //id автоматически создается с помощью автоинкремента поэтому null
  final String email;
  final String firstName; //Имя
  final String lastName; // Отчество
  final String passwordHash; //В субд будет сохраняться зашифрованный пароль
  final UserRole role;
  User({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'passwordHash': passwordHash,
      'role': role.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    final roleStr = map['role'] as String;
    final UserRole role;
    switch (roleStr) {
      case 'doctor':
        role = Doctor(generatedCode: map['generated_code'] as String? ?? '');
      case 'patient':
        role = Patient(referralCode: map['referral_code'] as String? ?? '');
      default:
        throw ArgumentError('Unknown role: $roleStr');
    }
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      passwordHash: map['password_hash'] as String,
      role: role,
    );
  }
  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //       email.hashCode ^
  //       firstName.hashCode ^
  //       lastName.hashCode ^
  //       passwordHash.hashCode ^
  //       role.hashCode;
  // }
}
