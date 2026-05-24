import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:server_trauma_1/database/dto/create_user_dto.dart';
import 'package:server_trauma_1/database/models/role_model.dart';

import '../database/database.dart';
import '../database/models/user_model.dart';

class UserService {
  final Database db;
  UserService(this.db);

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final _random = Random.secure();

  // генерация уникального 5-значного кода
  String _generateUniqueCode() {
    while (true) {
      final code = List.generate(
        5,
        (_) => _chars[_random.nextInt(_chars.length)],
      ).join();

      if (!db.codeExists(code)) return code;
    }
  }

  // хеширование пароля
  String _hashPassword(String raw) {
    final bytes = utf8.encode(raw);
    return sha256.convert(bytes).toString();
  }

  // создание пользователя
  User create(CreateUserDto dto) {
    // проверяем уникальность email
    if (db.emailExists(dto.email)) {
      throw ArgumentError('email already exists');
    }

    // собираем роль
    final role = switch (dto.role) {
      'doctor' => Doctor(generatedCode: _generateUniqueCode()),
      'patient' => Patient(referralCode: dto.referralCode!),
      _ => throw ArgumentError('Unknown role: ${dto.role}'),
    };

    return db.createUser(
      firstName: dto.firstName,
      lastName: dto.lastName,
      email: dto.email,
      passwordHash: _hashPassword(dto.password),
      role: role.role,
      generatedCode: switch (role) {
        Doctor d => d.generatedCode,
        Patient _ => null,
      },
      referralCode: switch (role) {
        Patient p => p.referralCode,
        Doctor _ => null,
      },
    );
  }
}
