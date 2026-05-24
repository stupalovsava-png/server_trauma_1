import 'package:relic/relic.dart';
import 'database/database.dart';
import 'handlers/users_handler.dart';
import 'services/user_service.dart';

class App {
  late final RelicApp _app;

  App() {
    // инициализируем зависимости
    final db = Database();
    final userService = UserService(db);
    final usersHandler = UsersHandler(userService);

    _app = RelicApp()..post('/users', usersHandler.createUser);
  }

  Future<void> serve({int port = 8080}) async {
    await _app.serve(port: port);
    print('Server running at http://localhost:$port');
  }
}
