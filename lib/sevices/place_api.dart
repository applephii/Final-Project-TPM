import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:studybuddy/models/place.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studybuddy/sevices/session.dart';

class PlaceApi {
  static final String? _baseUrl = dotenv.env['MY_API'];

  static Future<List<Place>> fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/places'));

      if (response.statusCode != 200) {
        throw Exception('Failed to load places: ${response.statusCode}');
      }

      final body = json.decode(response.body);

      if (body is! List) {
        throw Exception(
          'Expected a list from /places but got: ${body.runtimeType}',
        );
      }

      return body
          .where((item) => item != null)
          .map<Place>((item) => Place.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching places: $e');
      rethrow;
    }
  }

  static Future<List<Place>> fetchFavouritePlaces() async {
  final userId = await SessionService.getUserId();

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/favourite-places?userId=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load favourite places: ${response.statusCode}',
      );
    }

    final body = json.decode(response.body);
    debugPrint('Favourite places response: $body');

    if (body is! List) {
      throw Exception(
        'Expected a list from /favourite-places but got: ${body.runtimeType}',
      );
    }

    return body
        .where((item) => item != null)
        .map<Place>((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error fetching favourite places: $e');
    rethrow;
  }
}


  static Future<void> addFavouritePlace(int placeId) async {
    final uID = await SessionService.getUserId();
    final response = await http.post(
      Uri.parse('$_baseUrl/favourite-places'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': int.parse(uID!), 'placeId': placeId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add favourite');
    }
  }

  static Future<void> removeFavouritePlace(int placeId) async {
    final uID = await SessionService.getUserId();
    final response = await http.delete(
      Uri.parse('$_baseUrl/favourite-places/$placeId?userId=$uID'),
    );
    debugPrint("Trying to delete fav place with: $uID, $placeId");
    if (response.statusCode != 200) {
      throw Exception('Failed to remove favourite');
    }
  }
}
