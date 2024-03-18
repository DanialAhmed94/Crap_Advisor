import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../apis/fetchFestivals.dart';
import '../models/festivalsDetail_model.dart';
import '../services/getuser_location.dart';
import '../services/getCustomMarker.dart';
import 'modalbottamsheet.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _controller;
  List<Marker> _markers = [];
  List<Festival> festivals = [];
  late Festivals fetchedFestivals;
  BitmapDescriptor? _customMarkerIcon; // Variable to store custom marker icon

  @override
  void initState() {
    super.initState();
    _setupMap();
    _fetchCustomMarker(); // Fetch custom marker icon
  }

  Future<void> _setupMap() async {
    try {
      final Position position = await getUserLocation();
      final LatLng latLng = LatLng(position.latitude, position.longitude);

      await fetchFestivalsData();

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: latLng,
          infoWindow: InfoWindow(title: 'Your Current Location'),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
      for (final festival in festivals) {
        _markers.add(
          Marker(
            markerId: MarkerId(festival.id.toString()),
            position: LatLng(double.parse(festival.latitude), double.parse(festival.longitude)),
            infoWindow: InfoWindow(title: festival.description),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker, // Use custom marker icon if available
            onTap: () {
              showMarkerInfo(context, festival);
            },
          ),
        );
      }
    });

      _controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    } catch (e) {
      print("Error setting up map: $e");
    }
  }

  // Asynchronous operation to fetch custom marker icon
  Future<void> _fetchCustomMarker() async {
    try {
      _customMarkerIcon = await getCustomMarker();
    } catch (e) {
      print("Error fetching custom marker icon: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0), // Initial value doesn't matter since we update it later
            zoom: 14,
          ),
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
                if (locationData != null) {
                  print("my location");
                  print("${locationData.latitude}, ${locationData.longitude}");
                  _markers.add(Marker(
                    icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0),
                    infoWindow: InfoWindow(title: "Your current location"),
                  ));
                  CameraPosition newCameraPosition = CameraPosition(
                    target: LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0),
                    zoom: 14,
                  );
                  GoogleMapController googleMapController = await _controller;
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(newCameraPosition),
                  );
                  setState(() {}); // Update UI with new marker
                }
              }).catchError((error) {
                print("Error getting location: $error");
              });
            },
            child: Icon(Icons.my_location_outlined),
          ),
        ),
      ],
    );
  }

  Future<void> fetchFestivalsData() async {
    try {
      fetchedFestivals = await fetchFestivals("https://stagingcrapadvisor.semicolonstech.com/api/festival");
      festivals = fetchedFestivals.data;
    } catch (e) {
      print("Error fetching festivals data: $e");
    }
  }
}
