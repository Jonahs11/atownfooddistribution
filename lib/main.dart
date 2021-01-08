import 'package:atownfooddistribution/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/SuperListener.dart';

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
            mapPage
          ],
        )
        );
  }
}
