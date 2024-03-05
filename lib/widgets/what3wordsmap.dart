import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  TextEditingController _what3WordsController = TextEditingController();
   Marker? marker = null;

  // The grid overlay is going to be drawn manually using polylines
  Set<Polyline> _gridLines = {};
  @override
  void dispose() {
    _what3WordsController.dispose();
    super.dispose();
  }

  void _generateGrid(LatLngBounds bounds) {
    final double step = 0.0001; // This represents the approximate size of a what3words square
    _gridLines.clear();

    // Calculate the number of grid lines needed
    int latLines = ((bounds.northeast.latitude - bounds.southwest.latitude) /
        step).ceil();
    int lngLines = ((bounds.northeast.longitude - bounds.southwest.longitude) /
        step).ceil();

    // Create latitude lines
    for (int i = 0; i <= latLines; i++) {
      double lat = bounds.southwest.latitude + (step * i);
      _gridLines.add(
        Polyline(
          polylineId: PolylineId('lat_$i'),
          points: [
            LatLng(lat, bounds.southwest.longitude),
            LatLng(lat, bounds.northeast.longitude),
          ],
          color: Colors.blue,
          width: 1, // Increased width for visibility at high zoom levels
        ),
      );
    }

    // Create longitude lines
    for (int i = 0; i <= lngLines; i++) {
      double lng = bounds.southwest.longitude + (step * i);
      _gridLines.add(
        Polyline(
          polylineId: PolylineId('lng_$i'),
          points: [
            LatLng(bounds.southwest.latitude, lng),
            LatLng(bounds.northeast.latitude, lng),
          ],
          color: Colors.blue,
          width: 1, // Increased width for visibility at high zoom levels
        ),
      );
    }

    setState(() {});
  }

  void _onCameraMove(CameraPosition position) async {
    if (mapController != null) {
      LatLngBounds bounds = await mapController!.getVisibleRegion();
      _generateGrid(bounds);
    }
    setState(() {
      _what3WordsController.clear();

    });
  }
  void _onMapTap(LatLng latLng) async {

    String? what3Words = await convertToWhat3Words(latLng.latitude, latLng.longitude);
    setState(() {
      _what3WordsController.text = what3Words ?? 'Unable to fetch What3Words address';

      if (marker != null) {
        marker = Marker(
          markerId: MarkerId("3"),
          position: latLng,
        );
      } else {
        marker = Marker(
          markerId: MarkerId("3"),
          position: latLng,
        );
    }
    });
  }
  Future<String?> convertToWhat3Words(double lat, double lng) async {
    const apiKey = 'E1NAKJWV';
    final url = "https://api.what3words.com/v3/convert-to-3wa?coordinates=$lat%2C$lng&key=E1NAKJWV";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['words'];
    } else {
      throw Exception('Failed to get What3Words address');
    }
  }
  // This function generates the grid overlay


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextFormField(
            controller: _what3WordsController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'What3Words Address',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: GoogleMap(
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMove: _onCameraMove,
            onTap: _onMapTap,
            initialCameraPosition: CameraPosition(
              target: LatLng(52.4862, -1.8904), // Center on London
              zoom: 20,
            ),
            polylines: _gridLines,
            zoomControlsEnabled: false,
            markers: marker != null ? Set<Marker>.of([marker!]) : {},


          ),
        ),

      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class What3WordsMap extends StatefulWidget {
//   final LatLng coordinates;
//
//
//   What3WordsMap({required this.coordinates});
//
//   @override
//   State<What3WordsMap> createState() => _What3WordsMapState();
// }
//
// class _What3WordsMapState extends State<What3WordsMap> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
//
// }
//
//
// Future<String> convertToWhat3Words(double lat, double lng) async {
//   const apiKey = 'E1NAKJWV';
//   final url = "https://api.what3words.com/v3/convert-to-3wa?coordinates=$lat%2C$lng&key=E1NAKJWV";
//   final response = await http.get(Uri.parse(url));
//
//   if (response.statusCode == 200) {
//     final jsonResponse = json.decode(response.body);
//     return jsonResponse['words'];
//   } else {
//     throw Exception('Failed to get what3words address');
//   }
// }