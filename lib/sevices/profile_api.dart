import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studybuddy/models/user.dart';
import 'package:studybuddy/sevices/session.dart';

class ProfileApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<UserModel?> getUserById() async {
    try {
      final userId = await SessionService.getUserId();
      final uid = int.parse(userId!);

      final res = await http.get(Uri.parse('$_baseUrl/users/$uid'));
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final user = jsonData['data'];
        return UserModel.fromJson(user);
      } else {
        print('Error: Failed to fetch user (status ${res.statusCode})');
        return null;
      }
    } catch (e) {
      print('Exception in getUserById: $e');
      return null;
    }
  }

  static Future<bool> updateUser({
    String? username,
    String? email,
    String? password,
  }) async {
    try {
      final userId = await SessionService.getUserId();
      final uid = int.parse(userId!);

      final Map<String, dynamic> updateData = {};
      if (username != null && username.isNotEmpty)
        updateData['username'] = username;
      if (email != null && email.isNotEmpty) updateData['email'] = email;
      if (password != null && password.isNotEmpty)
        updateData['password'] = password;

      final response = await http.put(
        Uri.parse('$_baseUrl/users/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);

        if (response.statusCode == 400 && errorData['errors'] != null) {
          throw errorData['errors'];
        } else {
          final msg = errorData['message'] ?? 'Unknown server error';
          throw msg;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteUser() async {
    try {
      final userId = await SessionService.getUserId();
      final uid = int.parse(userId!);

      final response = await http.delete(Uri.parse('$_baseUrl/users/$uid'));
      return response.statusCode == 200;
    } catch (e) {
      print('Exception in deleteUser: $e');
      return false;
    }
  }
}
