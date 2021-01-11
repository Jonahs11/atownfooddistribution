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
    Card tempCard;
    widget.myLocs.forEach((key, value) {
      tempCard = Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Row(
          children: [
            Text(
              key
            ),
            IconButton(icon: Icon(Icons.edit), onPressed: () {
              print("Editing $key");
            })
          ],
        ),
      );

      containers.add(tempCard);
    });

    return containers;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("List of Locations"),
            IconButton(icon: Icon(Icons.close), onPressed: () {
                SuperListener.removeListLocScreen();
            })
          ],
        ),
      ),
      body: (
      ListView(
        children: loadPlaces()
      )
      )
    );
  }
}
