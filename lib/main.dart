import 'package:atownfooddistribution/InformationPage.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/LocationList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  int myIndex = 0;
  WelcomeScreen welcomeScreen = new WelcomeScreen();
  MapPage mapPage = new MapPage();
  InformationPage informationPage = new InformationPage();
  LocationList locationList = new LocationList();
  bool oneClick = false;

  @override
  void initState() {
    SuperListener.setPages(hPage: this);
    super.initState();
  }

  void screenChanger(int newIndex) {
    setState(() {
      myIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: IndexedStack(
          index: myIndex,
          children: [
            welcomeScreen,
            mapPage,
            locationList,
            informationPage,
          ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        currentIndex: myIndex,
       selectedItemColor: Colors.red,
       // selectedItemColor: Colors.red,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new_rounded),
              label: "Welcome Screen",
            backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Map Page"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Location List"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "Information Page"
          ),
        ],
        onTap: (int index) {
          setState(() {
            if(!oneClick) {
              SuperListener.updateLocList();
              oneClick = true;
            }
            myIndex = index;
          });
        } ,
      ),
        );
  }
}
