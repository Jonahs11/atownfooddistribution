import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';

class LocationList extends StatefulWidget {

  final Map myLocs;
  const LocationList(this.myLocs);

  @override
  LocationListState createState() => LocationListState();
}

class LocationListState extends State<LocationList> {

  List<String> keys = [];

  @override
  void initState() {
    SuperListener.setPages(lPage: this);
    super.initState();
  }

  void loadKeys() {
    widget.myLocs.keys.forEach((element) {
     print(element);
    });
  }

  List loadPlaces() {
    List<Widget> containers = [];
    Container tempContainer;
    widget.myLocs.forEach((key, value) {
      tempContainer = new Container(
        child: Text(
          key
        ),
      );

      containers.add(tempContainer);
    });

    return containers;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Locations"),
      ),
      body: (
      ListView(
        children: loadPlaces()
      )
      )
    );
  }
}
