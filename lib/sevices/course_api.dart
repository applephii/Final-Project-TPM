import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  // Get all courses (with optional mentorId filter)
  static Future<List<MentorCourse>> getCourses(int mentorId) async {
    try {
      final uri = Uri.parse('$_baseUrl/courses?mentorId=$mentorId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MentorCourse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch courses');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all courses (no filtering)
  static Future<List<MentorCourse>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/allcourses'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MentorCourse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch all courses');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<MentorCourse> getCourseById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/courses/$id'));

    if (response.statusCode == 200) {
      return MentorCourse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Course not found');
    }
  }

  static Future<MentorCourse> createCourse(MentorCourse course) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 201) {
      return MentorCourse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create course');
    }
  }

  static Future<MentorCourse> updateCourse(MentorCourse course) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/courses/${course.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200) {
      return MentorCourse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course');
    }
  }

  // Delete course
  static Future<void> deleteCourse(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/courses/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course');
    }
  }
}
