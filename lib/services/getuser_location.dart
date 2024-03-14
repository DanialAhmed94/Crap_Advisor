//
// import 'package:location/location.dart';
//
// Future<LocationData> getUserLocation() async {
//   Location location = new Location();
//
//   bool _serviceEnabled;
//   PermissionStatus _permissionGranted;
//   LocationData _locationData;
//
//   // Check if location services are enabled.
//   _serviceEnabled = await location.serviceEnabled();
//   if (!_serviceEnabled) {
//     _serviceEnabled = await location.requestService();
//     if (!_serviceEnabled) {
//       throw Exception("Location services are disabled.");
//     }
//   }
//
//   // Check for permission to access location.
//   _permissionGranted = await location.hasPermission();
//   if (_permissionGranted == PermissionStatus.denied) {
//     _permissionGranted = await location.requestPermission();
//     if (_permissionGranted != PermissionStatus.granted) {
//       throw Exception("Location permission denied.");
//     }
//   }
//
//   // Get the current location.
//   _locationData = await location.getLocation();
//   return _locationData;
// }
import 'package:geolocator/geolocator.dart';

Future<Position> getUserLocation() async {
  LocationPermission permission;

  // Check if location services are enabled.
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Since we can't programmatically request the user to enable location services,
    // you should instruct the user to do so manually if this exception is caught.
    throw Exception("Location services are disabled.");
  }

  // Check for permission to access location.
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception("Location permission denied.");
    }
  }

  // Get the current location.
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return position;
}

