import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:studybuddy/models/mentor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studybuddy/sevices/session.dart';

class MentorApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<List<Mentor>> fetchMentors() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/mentors'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load mentors: ${response.statusCode}');
      }

      final body = json.decode(response.body);

      if (body is! List) {
        throw Exception(
          'Expected a list from /mentors but got: ${body.runtimeType}',
        );
      }

      return body
          .where((item) => item != null)
          .map<Mentor>((item) => Mentor.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching mentors: $e');
      rethrow;
    }
  }

  static Future<List<Mentor>> fetchFavouriteMentors() async {
  final userId = await SessionService.getUserId();

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/connected-mentors?userId=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load connected mentors: ${response.statusCode}',
      );
    }

    final body = json.decode(response.body);
    debugPrint('connected mentors response: $body');

    if (body is! List) {
      throw Exception(
        'Expected a list from /connected-mentors but got: ${body.runtimeType}',
      );
    }

    return body
        .where((item) => item != null)
        .map<Mentor>((item) => Mentor.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching connected mentors: $e');
    rethrow;
  }
}


  static Future<void> addFavouriteMentor(int mentorId) async {
    final uID = await SessionService.getUserId();
    final response = await http.post(
      Uri.parse('$_baseUrl/connected-mentors'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': int.parse(uID!), 'mentorId': mentorId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed connect to mentors');
    }
  }

  static Future<void> removeFavouriteMentor(int mentorId) async {
    final uID = await SessionService.getUserId();
    final response = await http.delete(
      Uri.parse('$_baseUrl/connected-mentors/$mentorId?userId=$uID'),
    );
    debugPrint("Trying to delete connection mentors with: $uID, $mentorId");
    if (response.statusCode != 200) {
      throw Exception('Failed remove connection to mentors');
    }
  }
}
