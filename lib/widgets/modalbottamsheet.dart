import 'package:crapadvisor/models/festivalsDetail_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/what3words.dart';

showMarkerInfo(BuildContext context, Festival festival) {
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: festival.image != null && festival.image.isNotEmpty
                    ? Padding(
                  padding: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://stagingcrapadvisor.semicolonstech.com/asset/festivals/" +
                          festival.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // If an error occurs while loading the image, show the default image
                        return Image.asset(
                          "assets/icons/logo.png",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/icons/logo.png",
                    fit: BoxFit.cover,
                  ),
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
                        "${festival.description}",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.0,
                            fontFamily: "Poppins-Bold"),
                      ),
                    ),
                  ),
                  Text(
                    "Date: ${festival.startingDate}",
                    style: TextStyle(
                      fontFamily: "Poppins-Medium",
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    "Time: ${festival.time}",
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
                                        festivalLocation: LatLng(
                                            double.parse(festival.latitude),
                                            double.parse(festival.longitude)),
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
