import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PhotoApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<String?> uploadPhoto(String userId, File imageFile) async {
    final url = Uri.parse('$_baseUrl/users/$userId/upload-photo');

    final mimeType = lookupMimeType(imageFile.path);
    final mediaType = MediaType.parse(mimeType ?? 'image/jpeg');

    final request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
          contentType: mediaType,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final relativeUrl = data['data'];
        final r = relativeUrl['photo_url'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        return "$_baseUrl$r?t=$timestamp";
      } catch (e) {
        print('JSON Decode Error: $e');
        return null;
      }
    }

    return null;
  }

  static Future<bool> deletePhoto(String userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/delete-photo');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Photo deleted');
      return true;
    } else {
      print("Error deleting photo: ${response.body}");
      return false;
    }
  }

static Future<String?> getProfilePhotoUrl(String userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final relativeUrl = data['data'];
        final r = relativeUrl['photo_url'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        return "$_baseUrl$r?t=$timestamp";
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }

    return null;
  }

}
