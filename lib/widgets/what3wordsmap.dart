import 'dart:async';
import 'package:crapadvisor/screens/selectFacility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/getCustomMarker.dart';

class MapScreen extends StatefulWidget {
  final LatLng intialCameraPosition;

  MapScreen({required this.intialCameraPosition});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  TextEditingController _what3WordsController = TextEditingController();
  Marker? marker = null;
  bool isSnackBarVisible = false;
  double buttonPosition = 16;
  Set<Polyline> _gridLines = {};
  BitmapDescriptor? _customMarkerIcon; // Variable to store custom marker icon


  @override
  void dispose() {
    super.dispose();
    _what3WordsController.dispose();
    _what3WordsController.dispose();

  }
  @override
  void initState(){
    super.initState();
    _fetchCustomMarker();
  }
  Future<void> _fetchCustomMarker() async {
    try {
      _customMarkerIcon = await getCustomMarker();
    } catch (e) {
      print("Error fetching custom marker icon: $e");
    }
  }
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
              labelStyle: TextStyle(
                fontFamily: "Poppins-Medium",
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => _onMapCreated(controller),
                onCameraMove: _onCameraMove,
                onTap: _onMapTap,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.intialCameraPosition.latitude,
                      widget.intialCameraPosition.longitude),
                  // Center on London
                  zoom: 20,
                ),
                polylines: _gridLines,
                zoomControlsEnabled: false,
                markers: marker != null ? Set<Marker>.of([marker!]) : {},
                myLocationButtonEnabled: false,
              ),
              AnimatedPositioned(
                bottom: buttonPosition,
                left: 0,
                right: 0,
                duration: Duration(milliseconds: 300),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.2,
                        right: MediaQuery.of(context).size.width * 0.2),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (marker == null) {
                            setState(() {
                              buttonPosition =
                                  40.0; // Move button upwards when Snackbar is shown
                            });
                            if (!isSnackBarVisible) {
                              isSnackBarVisible = true;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(" Select a position first"),
                                duration: Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Close',
                                  onPressed: () {
                                    // Hide the SnackBar when the action is pressed
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ));
                              _resetSnackBarFlagAfterDelay();
                            }
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectFacilty()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF445EFF),
                        ),
                        child: Text(
                          "Post Review",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: "Poppins-Medium",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      if (widget.intialCameraPosition != null) {
        controller.moveCamera(
          CameraUpdate.newLatLngZoom(widget.intialCameraPosition, 20),
        );
      }
    });
  }

  void _onMapTap(LatLng latLng) async {
    String? what3Words =
        await convertToWhat3Words(latLng.latitude, latLng.longitude);
    setState(() {
      _what3WordsController.text =
          what3Words ?? 'Unable to fetch What3Words address';

      if (marker != null) {
        marker = Marker(
          markerId: MarkerId("3"),
          position: latLng,
          icon:_customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        );
      } else {
        marker = Marker(
          markerId: MarkerId("3"),
          position: latLng,
            icon:_customMarkerIcon ?? BitmapDescriptor.defaultMarker
        );
      }
    });
  }

  Future<String?> convertToWhat3Words(double lat, double lng) async {
    const apiKey = 'E1NAKJWV';
    final url =
        "https://api.what3words.com/v3/convert-to-3wa?coordinates=$lat%2C$lng&key=E1NAKJWV";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['words'];
    } else {
      throw Exception('Failed to get What3Words address');
    }
  }

  void _generateGrid(LatLngBounds bounds) {
    final double step =
        0.0001; // This represents the approximate size of a what3words square
    _gridLines.clear();

    // Calculate the number of grid lines needed
    int latLines =
        ((bounds.northeast.latitude - bounds.southwest.latitude) / step).ceil();
    int lngLines =
        ((bounds.northeast.longitude - bounds.southwest.longitude) / step)
            .ceil();

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
      marker = null;
    });
  }

  void _resetSnackBarFlagAfterDelay() {
    const delay = Duration(seconds: 2);
    Timer(delay, () {
      setState(() {
        isSnackBarVisible = false;
        buttonPosition = 16;
      });
    });
  }
}
