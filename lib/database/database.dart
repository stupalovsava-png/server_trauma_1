import 'package:sqlite3/sqlite3.dart';
import 'models/user_model.dart';

class Database {
  final db = sqlite3.open('trauma.db');

  Database() {
    _init();
  }

  void _init() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName      TEXT    NOT NULL,
        lastName       TEXT    NOT NULL,
        email          TEXT    UNIQUE NOT NULL,
        password_hash  TEXT    NOT NULL,
        role           TEXT    NOT NULL,
        generated_code TEXT,
        referral_code  TEXT
      )
    ''');
  }

  // CREATE
  User createUser({
    required String firstName,
    required String lastName,

    required String email,
    required String passwordHash,
    required String role,
    String? generatedCode,
    String? referralCode,
  }) {
    db.execute(
      '''
        INSERT INTO users 
          (firstName, lastName, email, password_hash, role, generated_code, referral_code)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        firstName,
        lastName,
        email,
        passwordHash,
        role,
        generatedCode,
        referralCode,
      ],
    );

    return getById(db.lastInsertRowId)!;
  }

  // READ
  User? getById(int id) {
    final rows = db.select('SELECT * FROM users WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  bool emailExists(String email) {
    final rows = db.select('SELECT id FROM users WHERE email = ?', [email]);
    return rows.isNotEmpty;
  }

  bool codeExists(String code) {
    final rows = db.select('SELECT id FROM users WHERE generated_code = ?', [
      code,
    ]);
    return rows.isNotEmpty;
  }

  void close() => db.close();
}
