// service_checks.dart

import 'package:connectivity/connectivity.dart';
import 'package:location/location.dart';

/// Checks for an active internet connection.
Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}


/// Checks the status of the location service.
/// Returns true if the location service is enabled and permissions are granted.
/// Returns false if the location service is disabled or permission is denied.
/// Returns null if the location service is disabled and the user denied permission.
Future<bool> checkLocationService() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  try {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false; // Permission denied after re-prompting
      }
    }

    _locationData = await location.getLocation();
    // You may use _locationData if needed.
    return true; // Location service check succeeded.
  } catch (e) {
    print("Error checking location service: $e");
    return false; // Location service check failed due to an error.
  }
}

// ... (existing code)


