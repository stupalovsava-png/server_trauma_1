1) Клиент отправляет json
{
  "firstName": "Ivan",
  "lastName": "Petrov",
  "email": "ivan@mail.com",
  "password": "secret123",
  "role": "doctor"
}

2) UsersHandler.createUser() (handlers/users_handler.dart)

Читает тело запроса как строку → utf8.decodeStream(req.body.read())
Парсит JSON → jsonDecode(bodyStr)
Создаёт CreateUserDto через фабричный метод CreateUserDto.fromMap(body)
Вызывает dto.validate() — проверяет длину пароля, email, наличие referralCode для пациента и т.д.
Если всё ок — вызывает service.create(dto)
Обрабатывает возможные ошибки: ArgumentError → 400, другие ошибки → 500.

3) UserService.create() (services/user_service.dart)

Проверяет, не занят ли email (db.emailExists(...)) — если занят, кидает ArgumentError
В зависимости от dto.role создаёт объект Doctor или Patient (sealed class UserRole)
Для doctor генерирует уникальный 5-значный код: _generateUniqueCode() (цикл с проверкой в БД)
Для patient берёт dto.referralCode (обязательно, иначе валидация не пропустит)
Хеширует пароль через SHA256: _hashPassword(dto.password)
Вызывает db.createUser(...) передавая отдельно поля: firstName, lastName, email, passwordHash, role (строку), generatedCode или referralCode (другое — null)
Возвращает полученный из БД объект 
atabase.createUser() (database/database.dart)

4) Выполняет INSERT в таблицу users:
sql
INSERT INTO users (firstName, lastName, email, password_hash, role, generated_code, referral_code)
VALUES (?, ?, ?, ?, ?, ?, ?)
После вставки получает db.lastInsertRowId
Возвращает результат getById(lastInsertRowId)

5) Database.getById()

Выполняет SELECT * FROM users WHERE id = ?
Получает строку — Map<String, dynamic> с ключами: id, firstName, lastName, email, password_hash, role, generated_code, referral_code
Вызывает User.fromMap(rows.first)
6) User.fromMap() (models/user_model.dart)

Читает role как строку
По значению 'doctor' или 'patient' создаёт соответствующий объект Doctor или Patient, читая generated_code или referral_code из того же Map
Читает остальные поля: id, email, firstName, lastName, password_hash (внимание: имя колонки в БД — password_hash, а в классе поле — passwordHash)
Возвращает готовый объект User
7) Возвращаемся в UserService.create() → теперь есть User

Сервис возвращает этого пользователя в UsersHandler
8) UsersHandler создаёт UserResponseDto.fromUser(user)

Маппит поля, исключая passwordHash
Для Doctor выставляет generatedCode, для Patient — referralCode, другое поле null
Формирует JSON через jsonEncode(response.toMap())
Отвечает с HTTP статусом 201 Created
