import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

class RouteService {
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final apiKey = dotenv.env['ORS_API_KEY'];
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
    );

    final body = json.encode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': apiKey ?? '',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // print('Route response: ${response.body}');
      final data = json.decode(response.body);
      final List coords = data['features'][0]['geometry']['coordinates'];
      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Failed to load route: ${response.body}');
    }
  }
}
