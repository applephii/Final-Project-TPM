import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userdata = data['data'];
      return {
        'id': userdata['id'].toString(),
        'username': userdata['username'],
        'email': userdata['email'],
        'photoUrl': userdata['photo_url'],
      };
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message']?.toString() ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final userdata = data['data'];
      return {
        'id': userdata['id'].toString(),
        'username': userdata['username'],
        'email': userdata['email'],
        'photoUrl': userdata['photo_url'],
      };
    } else {
      final errorData = jsonDecode(response.body);
      if (errorData['errors'] != null) {
        throw Exception(errorData['errors'].toString());
      }
      throw Exception(
        errorData['message']?.toString() ?? 'Registration failed',
      );
    }
  }
}
