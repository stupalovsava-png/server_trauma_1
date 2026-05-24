import 'package:server_trauma_1/app.dart';

Future<void> main() async {
  final app = App();
  await app.serve(port: 8080);
}
