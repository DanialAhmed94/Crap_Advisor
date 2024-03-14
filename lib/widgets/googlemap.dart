import 'package:crapadvisor/screens/what3words.dart';
import 'package:crapadvisor/widgets/modalbottamsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../apis/fetchFestivals.dart';
import '../models/festivalsDetail_model.dart';
import '../services/getuser_location.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}
class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late CameraPosition _kGooglePlex = CameraPosition(target: LatLng(0, 0),);
  late LatLng latlng = LatLng(0, 0);
  late GoogleMapController _controller;
  List<Marker> _markers = [];
  List<Festival> festivals = [];
  late Festivals fetchedFestivals;

  @override
  void initState() {
    super.initState();
    initializeMapAndFetchData();

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            _moveCameraToCurrentUserLocation();
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
  Future<void> _setupMarkers() async {
    // Create a marker for the user's current location
    final userLocationMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: latlng,
      infoWindow: InfoWindow(title: 'Your Current Location'),
      icon: await _getCustomMarker(),
    );
    _markers.add(userLocationMarker);
    for (final festival in festivals) {
      final festivalMarker = Marker(
        markerId: MarkerId(festival.id.toString()),
        position: LatLng(double.parse(festival.latitude), double.parse(festival.longitude)),
        infoWindow: InfoWindow(title: festival.description),
        icon: await _getCustomMarker(),
        onTap: (){showMarkerInfo(context, festival);},
      );
      _markers.add(festivalMarker);
    }

    setState(() {});
  }
  Future<void> initializeMapAndFetchData() async {
    await _initMap(); // Initialize the map with the user's current location.
    await fetchFestivalsData(); // Fetch festival data.
    await _setupMarkers(); // Setup markers after fetching data and initializing map.
  }
  Future<void> fetchFestivalsData() async {
    try {
      fetchedFestivals = await fetchFestivals(
          "https://stagingcrapadvisor.semicolonstech.com/api/festival");

        festivals = fetchedFestivals.data;

    } catch (e) {}
  }
  Future<void> _initMap() async {
    final Position locationData = await getUserLocation();
    latlng = LatLng(locationData.latitude, locationData.longitude);
    setState(() {
      _kGooglePlex = CameraPosition(target: LatLng(locationData.latitude, locationData.longitude), zoom: 14);
    });
  }
  Future<void> _moveCameraToCurrentUserLocation() async {
    if (_controller != null && latlng != LatLng(0, 0)) {
      await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(latlng.latitude, latlng.longitude), zoom: 14)));
      print("Camera moved to: ${latlng.latitude}, ${latlng.longitude}");
    }
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


}
