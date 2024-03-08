import 'package:crapadvisor/screens/what3words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../services/getuser_location.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0, 0),
  );
  late LatLng latlng = LatLng(0, 0);

  late GoogleMapController _controller;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initMap().then((_) {
      _initMarkers(latlng); // Call _initMarkers after _initMap is completed
    });
  }

  Future<void> _initMap() async {
    LocationData locationData = await getUserLocation();
    latlng = LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0);
    setState(() {
      _kGooglePlex = CameraPosition(target: latlng, zoom: 14);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          markers: Set<Marker>.of(_markers),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.08,
          right: MediaQuery.of(context).size.width * 0.05,
          child: ElevatedButton(
            onPressed: () async {
              getUserLocation().then((locationData) async {
                // Make sure to check if locationData is not null
                if (locationData != null) {
                  print("my location");
                  print("${locationData.latitude}, ${locationData.longitude}");
                  _markers.add(Marker(
                    icon: await _getCustomMarker(),
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(locationData.latitude ?? 0,
                        locationData.longitude ?? 0),
                    infoWindow: InfoWindow(title: "Your current location"),
                  ));
                  CameraPosition newCameraPosition = CameraPosition(
                    target: LatLng(locationData.latitude ?? 0,
                        locationData.longitude ?? 0),
                    zoom: 14, // Consider setting an appropriate zoom level
                  );
                  GoogleMapController googleMapController = await _controller;
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(newCameraPosition),
                  );
                  setState(() {});
                }
              }).catchError((error) {
                // Handle any errors here
                print("Error getting location: $error");
              });
            },
            child: Icon(Icons.my_location_outlined),
          ),
        )
      ],
    );
  }

  Future<void> _initMarkers(LatLng latLng) async {
    _markers = [
      Marker(
        markerId: MarkerId("1"),
        icon: await _getCustomMarker(),
        position: LatLng(52.4862, -1.8904),
        infoWindow: InfoWindow(title: "Crap Advisor"),
        onTap: () {
          _showMarkerInfo(context);
        },
      ),
      Marker(
        markerId: MarkerId("temp"),
        icon: await _getCustomMarker(),
        position: LatLng(latLng.latitude, latLng.longitude),
        infoWindow: InfoWindow(title: "Your Current Location"),
      )
    ]; // Update the UI after setting the markers
    setState(() {});
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    final Uint8List markerIcon = await _getBytesFromAsset(
        'assets/icons/marker.png',
        100); // Change the asset path and size as needed
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  _showMarkerInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              topLeft: Radius.circular(20.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                //   height: 10, // Set height equal to the total height of the bottom sheet
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/icons/logo.png",
                    fit: BoxFit
                        .cover, // Ensure the image covers the entire height of the container
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Container(
                        child: Text(
                          "Park Life Festival",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0,
                              fontFamily: "Poppins-Bold"),
                        ),
                      ),
                    ),
                    Text(
                      "Date: ${DateTime.now().toString()}",
                      style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Time: ${TimeOfDay.fromDateTime(DateTime.now()).toString()}",
                      style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        color: Colors.black54,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Container(
                        width: double.infinity, // Set your desired width here
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => What3WordsScreen(
                                          latlong: _markers[0].position,
                                        )));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF445EFF),
                          ),
                          child: Text(
                            "Details",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: "Poppins-Medium",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
