import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class My_Drawer extends StatelessWidget {
  const My_Drawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello Danial",style: TextStyle(fontFamily: 'Poppins-Bold'),),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            title: Text("Home",style: TextStyle(fontFamily: 'Poppins-Medium'),),
            leading:
                IconButton(onPressed: () {}, icon: Icon(Icons.home_outlined)),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text(" Toilet Ratings",style: TextStyle(fontFamily: 'Poppins-Medium'),),
            leading: IconButton(
                onPressed: () {},
                icon: Icon(Icons.dashboard_customize_outlined),
          ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text(" Share App",style: TextStyle(fontFamily: 'Poppins-Medium'),),
            leading: IconButton(onPressed: () {}, icon: Icon(Icons.share)),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text(" Feedback",style: TextStyle(fontFamily: 'Poppins-Medium'),),
            leading: IconButton(
                onPressed: () {}, icon: Icon(Icons.feedback_outlined)),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text(" Upcoming Products",style: TextStyle(fontFamily: 'Poppins-Medium'),),
            leading: IconButton(
                onPressed: () {}, icon: Icon(Icons.watch_later_outlined)),
          ),
          Spacer(),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8.0, left: 18.0),
                // Adjust the right padding based on your preference
                child: SvgPicture.asset('assets/svgs/logo-crap.svg',
                   height: 80,width: 80,
    fit: BoxFit.contain,
      ),
              ),
              Text(
                "Crap Adviser",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ]),
              )
            ],
          )
        ],
      ),
    );
  }
}
