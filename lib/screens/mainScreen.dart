import 'package:crapadvisor/widgets/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/googlemap.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crap Advisor',style: TextStyle(fontFamily: 'Poppins-Bold',fontWeight: FontWeight.bold),),
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
            icon: Icon(Icons.notifications_none_outlined)
          ),
        ],
      ),
      drawer: My_Drawer(),
      body: Stack(
        children: [
          GoogleMapWidget(), // Google Map widget at the bottom
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
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      Text("United Kingdom",style: TextStyle(fontFamily: 'Poppins-SemiBold',fontSize: 15),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}