import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studybuddy/models/task.dart';
import 'package:studybuddy/sevices/session.dart';

class TaskApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<List<Task>> getTasks() async {
    final uid = await SessionService.getUserId();
    final userId = int.parse(uid!);

    final url = Uri.parse('$_baseUrl/tasks?userId=$userId');
    final res = await http.get(url,
    headers: {
      'Content-Type': 'application/json',
    });

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  static Future<Task> getTaskById (int id) async {
    final uid = await SessionService.getUserId();
    final userId = int.parse(uid!);

    final url = Uri.parse('$_baseUrl/tasks/$id?userId=$userId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return Task.fromJson(data);
    } else {
      throw Exception('Failed to fetch task');
    }
  }

  static Future<bool> createTask(Task task) async {
    final uid = await SessionService.getUserId();
    final userId = int.parse(uid!);

    final url = Uri.parse('$_baseUrl/tasks?userId=$userId');
    final res = await http.post(url,
    headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    return res.statusCode == 201;
  }

  static Future<bool> updateTask(Task task) async {
    final uid = await SessionService.getUserId();
    final userId = int.parse(uid!);
    
    if (task.id == null) throw Exception("Task ID is null");
    final url = Uri.parse('$_baseUrl/tasks/${task.id}?userId=$userId');
    final res = await http.put(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    return res.statusCode == 200;
  }

  static Future<bool> deleteTask(int id) async {
    final uid = await SessionService.getUserId();
    final userId = int.parse(uid!);

    final url = Uri.parse('$_baseUrl/tasks/$id?userId=$userId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}