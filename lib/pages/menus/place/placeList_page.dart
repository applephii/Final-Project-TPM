import 'package:flutter/material.dart';
import 'package:studybuddy/models/place.dart';
import 'package:studybuddy/pages/menus/place/map_page.dart';
import 'package:studybuddy/sevices/loc_helper.dart';
import 'package:studybuddy/sevices/place_api.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:studybuddy/sevices/session.dart';

class PlacelistPage extends StatefulWidget {
  const PlacelistPage({super.key});

  @override
  State<PlacelistPage> createState() => _PlacelistPageState();
}

class _PlacelistPageState extends State<PlacelistPage> {
  bool showOnlyFavorites = false;
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  String _searchQuery = '';
  LocationData? _userLocation;
  List<Place> favoritePlaces = [];
  Set<int> _favoritePlaceIds = {};
  List<Place> _searchResult = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    reqAndLoad();
  }

  Future<void> reqAndLoad() async {
    await requestLocationPermission();
    await _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final userLoc = await getCurrentLocation();
      debugPrint('User location: $userLoc');

      final userID = await SessionService.getUserId();
      final places = await PlaceApi.fetchPlaces();
      if (places.isEmpty) {
        throw Exception('No places found');
      }

      if (userID != null) {
        favoritePlaces = await PlaceApi.fetchFavouritePlaces();
        _favoritePlaceIds = favoritePlaces.map((p) => p.id).toSet();
      }

      _applyFilters();

      if (userLoc != null &&
          userLoc.latitude != null &&
          userLoc.longitude != null) {
        final userLatLng = LatLng(userLoc.latitude!, userLoc.longitude!);
        final placeLatLng = LatLng(
          places.first.latitude,
          places.first.longitude,
        );
        final double distToFirstPlace = const Distance().as(
          LengthUnit.Meter,
          userLatLng,
          placeLatLng,
        );

        const maxAllowedDistance = 6000000.0;
        final useStatic = distToFirstPlace > maxAllowedDistance;

        if (useStatic) {
          debugPrint(
            'User too far from places. Using static location instead.',
          );
        }

        setState(() {
          _userLocation =
              useStatic
                  ? LocationData.fromMap({
                    'latitude': -7.782626885712409,
                    'longitude': 110.41601020961885,
                  })
                  : userLoc;
          _places = places;
          _filteredPlaces = places;
          _searchResult = places;
          _isLoading = false;
        });
      } else {
        debugPrint(
          'User location is null or incomplete. Using static location instead.',
        );
        setState(() {
          _userLocation = LocationData.fromMap({
            'latitude': -7.782626885712409,
            'longitude': 110.41601020961885,
          });
          _places = places;
          _filteredPlaces = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userLocation = LocationData.fromMap({
          'latitude': -7.782626885712409,
          'longitude': 110.41601020961885,
        });
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load places: $e')));
      debugPrint('Error loading places: $e');
    }
  }

  void _toggleFavorite(int placeId) async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites')),
      );
      return;
    }

    final wasFavorite = _favoritePlaceIds.contains(placeId);
    setState(() {
      if (wasFavorite) {
        _favoritePlaceIds.remove(placeId);
      } else {
        _favoritePlaceIds.add(placeId);
      }
    });

    try {
      if (wasFavorite) {
        await PlaceApi.removeFavouritePlace(placeId);
      } else {
        await PlaceApi.addFavouritePlace(placeId);
      }
    } catch (e) {
      setState(() {
        if (wasFavorite) {
          _favoritePlaceIds.add(placeId);
        } else {
          _favoritePlaceIds.remove(placeId);
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update favorite: $e')));
    }
  }

  void _searchPlaces(String query) {
    setState(() {
      _searchQuery = query;
      _searchResult =
          _places
              .where(
                (place) =>
                    place.name.toLowerCase().contains(query.toLowerCase()) ||
                    place.address.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      _applyFilters();
    });
  }

  void _sortByNearest() {
    if (_userLocation == null) return;

    setState(() {
      _filteredPlaces.sort((a, b) {
        final distanceA = const Distance().as(
          LengthUnit.Meter,
          LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
          LatLng(a.latitude, a.longitude),
        );
        final distanceB = const Distance().as(
          LengthUnit.Meter,
          LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
          LatLng(b.latitude, b.longitude),
        );
        return distanceA.compareTo(distanceB);
      });
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPlaces =
          showOnlyFavorites
              ? _searchResult
                  .where((place) => _favoritePlaceIds.contains(place.id))
                  .toList()
              : [..._searchResult];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Place', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: listPlaces()),
    );
  }

  Widget listPlaces() {
    return Column(
      children: [
        Column(
          children: [
            TextField(
              onChanged: _searchPlaces,
              decoration: InputDecoration(
                labelText: 'Search Places',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _sortByNearest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                    ),
                    child: Text(
                      'Sort by Nearest',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showOnlyFavorites = !showOnlyFavorites;
                        _applyFilters();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                    ),
                    child: Text(
                      showOnlyFavorites ? 'Show All' : 'Favourites',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPlaces.isEmpty
                  ? const Center(child: Text('No places found'))
                  : ListView.builder(
                    itemCount: _filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _filteredPlaces[index];
                      final isFavorite = _favoritePlaceIds.contains(place.id);
                      return Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          title: Text(
                            place.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(place.address),
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.bookmark_added_sharp
                                  : Icons.bookmark_add_outlined,
                              color: const Color.fromARGB(255, 45, 93, 141),
                            ),
                            onPressed: () => _toggleFavorite(place.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MapPage(
                                      centerPlace: place,
                                      userLocation: _userLocation!,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
