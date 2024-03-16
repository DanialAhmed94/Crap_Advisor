import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../apis/fetchFacilityType.dart';
import '../models/facilityType_model.dart';

class SelectFacilty extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset(
            'assets/svgs/drawer-icon.svg',
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          "Select Facility",
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<FacilityTypes>(
        future: fetchFacilityTypeData("https://stagingcrapadvisor.semicolonstech.com/api/toilet_type"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Facility> facilityList = snapshot.data!.facilityList;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: facilityList.length,
              itemBuilder: (context, index) {
                Facility facility = facilityList[index];
                return GridTile(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          facility.image,
                          fit: BoxFit.fill,
                          errorBuilder: (context,error,stackTrace){
                           return Image.asset("assets/icons/appLogo.png");
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        facility.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<FacilityTypes> fetchFacilityTypeData(String url) async {
    return fetchFacilityType(url);
  }
}
