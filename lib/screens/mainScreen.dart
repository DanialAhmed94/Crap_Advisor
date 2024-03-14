import 'package:flutter/material.dart';
import 'package:crapadvisor/widgets/drawer.dart';
import '../services/getuseraddres.dart';
import '../widgets/googlemap.dart';
import '../services/location_service.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Crap Advisor',
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.data == false) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Crap Advisor',
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Please enable internet and location services.',
                  style: TextStyle(
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Crap Advisor',
                style: TextStyle(
                  fontFamily: 'Poppins-Bold',
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: Image.asset(
                    "assets/icons/drawer-icon.png",
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_none_outlined),
                ),
              ],
            ),
            drawer: My_Drawer(),
            body: Stack(
              children: [
                GoogleMapWidget(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Location",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        FutureBuilder<String>(
                          future: getUserAddress(),
                          builder: (context, addressSnapshot) {
                            if (addressSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else
                            if (addressSnapshot.hasError) {
                              return Text('Error getting user address');
                            } else {
                              return Row(
                                children: [
                                  Icon(Icons.location_on_outlined),
                                  Text(
                                    addressSnapshot.data.toString() ?? 'Unknown Addresss',
                                    style: TextStyle(
                                      fontFamily: 'Poppins-SemiBold',
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  Future<bool> _checkServices() async {
    bool isInternetConnected = await checkInternetConnection();
    bool isLocationServiceEnabled = await checkLocationService();

    return isInternetConnected && isLocationServiceEnabled;
  }
}


