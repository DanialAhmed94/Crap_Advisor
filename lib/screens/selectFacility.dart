import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../apis/fetchFacilityType.dart';
import '../models/facilityType_model.dart';
import '../widgets/drawer.dart';

class SelectFacilty extends StatelessWidget {
 late String festivalvalId;
 late String latitude;
 late String longitude;
 late String what3wordsAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: Text(
          'Select Facility',
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(builder: (BuildContext context) {
          return
            IconButton(
              icon:SvgPicture.asset(
                'assets/svgs/drawer-icon.svg',
                fit: BoxFit.cover,
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
                return GestureDetector(
                  child: GridTile(
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
                            fontFamily: "Poppins-SemiBold",
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: (){

                  },
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
