import 'package:crapadvisor/screens/what3words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(52.4862, -1.8904), zoom: 12);

  late GoogleMapController _controller;

  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = [
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(52.4862, -1.8904),
        infoWindow: InfoWindow(title: "Crap Advisor"),
        onTap: () {
          _showMarkerInfo(context);
        },
      ),
    ];
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
                                    builder: (context) =>
                                        What3WordsScreen(latlong: _markers[0].position,)));
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

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
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
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.08,
          right: MediaQuery.of(context).size.width * 0.05,
          child: ElevatedButton(
            onPressed: () async {
              getUserLocation().then((value) async {
                print("my location");
                print(value.latitude + value.longitude);
                _markers.add(Marker(
                  markerId: MarkerId("currentLocation"),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: InfoWindow(title: "Your current location"),
                ));
                CameraPosition newCameraPosition = CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                );
                GoogleMapController googleMapController = await _controller;
                googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(newCameraPosition),
                );
                setState(() {});
              });
            },
            child: Icon(Icons.my_location_outlined),
          ),
        )
      ],
    );
  }
}
