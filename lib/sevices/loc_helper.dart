
import 'package:location/location.dart';

Location location = Location();

Future<LocationData?> getCurrentLocation() async {
  Location location = Location();
  try {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    LocationData currentLocation = await location.getLocation();
    return currentLocation;
  } catch (e) {
    print("Error getting location: $e");
    return null;
  }
}

Future<bool> requestLocationPermission() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      print('Location service not enabled');
      return false;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      print('Location permission denied');
      return false;
    }
  }
  print('Location permission granted');
  return true;
}

