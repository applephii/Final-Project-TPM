import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:studybuddy/models/place.dart';
import 'package:studybuddy/sevices/route_api.dart';
import 'package:studybuddy/sevices/session.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final Place centerPlace;
  final LocationData? userLocation;

  const MapPage({
    super.key,
    required this.centerPlace,
    required this.userLocation,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool showRoute = false;
  List<LatLng> routePoints = [];
  int routeRequestCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRouteRequestCount();
  }

  Future<void> _loadRouteRequestCount() async {
    final count = await SessionService.getRouteRequestCount();
    setState(() {
      routeRequestCount = count;
    });
    debugPrint('Current route request count: $count');
  }

  Future<void> _incrementRouteRequestCount() async {
    await SessionService.incrementRouteRequestCount();
    final newCount = await SessionService.getRouteRequestCount();
    setState(() {
      routeRequestCount = newCount;
    });
    debugPrint('Route request count incremented: $newCount');
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      widget.centerPlace.latitude,
      widget.centerPlace.longitude,
    );
    final userLoc = LatLng(
      widget.userLocation?.latitude ?? -7.782626885712409,
      widget.userLocation?.longitude ?? 110.41601020961885,
    );

    if (widget.userLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User location not available')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 18),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: center,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: userLoc,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
              if (showRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 45, 93, 141),
              label:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        showRoute ? 'Hide Route' : 'Show Route',
                        style: const TextStyle(color: Colors.white),
                      ),
              icon:
                  _isLoading
                      ? const SizedBox.shrink()
                      : Icon(
                        showRoute ? Icons.directions_off : Icons.directions,
                        color: Colors.white,
                      ),
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        print(userLoc);
                        print(center);
                        if (!showRoute) {
                          setState(() => _isLoading = true);
                          try {
                            final points = await RouteService.getRoute(
                              userLoc,
                              center,
                            );

                            setState(() {
                              routePoints = points;
                              showRoute = true;
                            });
                            await _incrementRouteRequestCount();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to fetch route: $e'),
                              ),
                            );
                          }
                          setState(() => _isLoading = false);
                        } else {
                          setState(() {
                            showRoute = false;
                            routePoints = [];
                          });
                        }
                      },
            ),
          ),
        ],
      ),
    );
  }
}
