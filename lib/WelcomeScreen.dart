import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:atownfooddistribution/LocationList.dart';
import 'package:location/location.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {

  bool locListUp = false;
  //LocationList locationList = new LocationList();

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(wScreen: this);
  }

  Widget welcomeScreen() {
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome!\n"
                  "",
                style: TextStyle(

                ),),
            ],
          ),

          SizedBox(height: 200,),
        ],
      ),
    );
  }

  void showLocs() {
    locations.forEach((key, value) {
      print(key);
    });
  }

  void changeToWelcome() {
    setState(() {
      locListUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return locListUp? LocationList(): welcomeScreen();
  }
}
