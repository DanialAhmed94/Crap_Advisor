import 'package:crapadvisor/widgets/what3wordsmap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/drawer.dart';

class What3WordsScreen extends StatefulWidget {
  final LatLng latlong;

  What3WordsScreen({required this.latlong});

  @override
  State<What3WordsScreen> createState() => _What3WordsScreenState();
}

class _What3WordsScreenState extends State<What3WordsScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
       body: MapScreen(),
      //    Stack(
   //      children: [
   //        MapScreen(),
   //      //  What3WordsMap(coordinates: widget.latlong),
   // //
   //      ],
   //    ),
    );
  }
}
