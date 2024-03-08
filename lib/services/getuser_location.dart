
import 'package:location/location.dart';

Future<LocationData> getUserLocation() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  // Check if location services are enabled.
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
  }

  // Check for permission to access location.
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      throw Exception("Location permission denied.");
    }
  }

  // Get the current location.
  _locationData = await location.getLocation();
  return _locationData;
}