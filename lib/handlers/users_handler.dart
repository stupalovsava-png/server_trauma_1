import 'dart:convert';
import 'package:relic/relic.dart';
import 'package:server_trauma_1/database/dto/create_user_dto.dart';
import 'package:server_trauma_1/database/dto/user_response_dto.dart';

import '../services/user_service.dart';

class UsersHandler {
  final UserService service;
  UsersHandler(this.service);

  Future<Response> createUser(Request req) async {
    final String bodyStr;
    try {
      bodyStr = await utf8.decodeStream(req.body.read());
      print('Body: $bodyStr');
    } catch (e) {
      print('Read error: $e');
      return Response.badRequest(body: Body.fromString('Cannot read body'));
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    } catch (e) {
      print('JSON error: $e');
      return Response.badRequest(body: Body.fromString('Invalid JSON'));
    }

    final CreateUserDto dto;
    try {
      dto = CreateUserDto.fromMap(body);
    } on FormatException catch (e) {
      return Response.badRequest(body: Body.fromString(e.message));
    }

    final error = dto.validate();
    if (error != null) {
      return Response.badRequest(body: Body.fromString(error));
    }

    try {
      final user = service.create(dto);
      final response = UserResponseDto.fromUser(user);

      return Response(201, body: Body.fromString(jsonEncode(response.toMap())));
    } on ArgumentError catch (e) {
      return Response.badRequest(body: Body.fromString(e.message));
    } catch (e) {
      print('Error: $e');
      return Response.internalServerError(
        body: Body.fromString('Something went wrong'),
      );
    }
  }
}
