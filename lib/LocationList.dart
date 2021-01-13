import 'dart:math';

import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';


class LocationList extends StatefulWidget {

  // final Map myLocs;
  // const LocationList(this.myLocs);

  @override
  LocationListState createState() => LocationListState();
}

class LocationListState extends State<LocationList> {

  List<String> keys = [];
  bool editing = false;
  String currentLoc;
  final formKey = GlobalKey<FormState>();
  List<Widget> places = [];
  RefreshController refreshController = RefreshController();
  final Distance distance = new Distance();

  @override
  void initState() {
    SuperListener.setPages(lPage: this);
    super.initState();
  }

  void loadKeys() {
    //widget.myLocs.keys.forEach((element)
    locations.keys.forEach((element)
    {
     print(element);
    });
  }

  void calcDistance(double lat1, double long1, double lat2, double long2) {
    final R = 6731000;
    double lat1r = lat1 * (pi / 180);
    double long1r = long1 * (pi / 180);
    double lat2r = lat2 * (pi / 180);
    double long2r = long2 * (pi / 180);

    double diffLat = (lat1r - lat2r).abs();
    double diffLong = (long1r - long2r).abs();

    double a = pow((sin(diffLat / 2)),2) + (cos(lat1r) * cos(lat2r) * pow((sin(diffLong / 2)), 2));
    double c = 2  * atan2(sqrt(a), sqrt(1-a));
    double d = R * c;
    print(d);

  }

  Future createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes, String link){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(name,
              style: TextStyle(
                  fontSize: 40.0
              ),),),
            //  SizedBox(
            //    width: 40.0,
            //  ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
        ,
        content: Column(
          children: [

            Text(address),
            Text("Current amount of food: $amountFood"),
            Text(notes),
            Row(
              children: [
                Text("Link:"),
                IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launch(link);
                  },
                )
              ],
            )
          ],
        ),
      );
    } );
  }

  void loadPlaces() {
    String name;
    String address;
    String foodLevel;
    String notes;
    String link;
    Widget tempWidget;
    Map<String, Future> popUps = {};
    locations.forEach((key, value)
    {
      // name = key;
      // address = value[0];
      // foodLevel = value[3];
      // notes = value[4];
      // link = value[5];
      // popUps[key] = SuperListener.createAlert(context, name, address, foodLevel, notes, link);

      tempWidget = GestureDetector(
        onTap: () {
          createAlertDialog(context, key, value[0], value[3], value[4], value[5]);
        },
        child: Card(
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Row(
            children: [
              Text(
                key
              ),
              IconButton(icon: Icon(Icons.edit), onPressed: () {
                print("Editing $key");
                setState(() {
                  currentLoc = key;
                  editing = true;
                });
              })
            ],
          ),
        ),
      );
      setState(() {
        places.add(tempWidget);
      });
    });
  }

  double getDistance(double lat1, double long1, double lat2, double long2) {
    double dist = distance.distance(LatLng(lat1, long1), LatLng(lat2, long2));
    print(dist);
    return dist;
  }

  void orderLocations() {
    List distancePerLoc = [];

    for(int i = 0; i < locations.length; i++){

    }

  }

  void updateFirebase(String foodLevel, String notes, String id) {
    SuperListener.updateFirebase(foodLevel, notes, id);
  }

  Widget editingPage(String key) {
    String name = key;
    String address = locations[key][0];
    String foodLevel = locations[key][3];
    String notes = locations[key][4];
    String docID = locations[key][6];
    TextEditingController myController1 = new TextEditingController(
      text: foodLevel
    );
    TextEditingController myController2 = new TextEditingController(
      text: notes
    );
    TextEditingController myController3 = new TextEditingController();
    TextEditingController myController4 = new TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Editing information for $key"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
                setState(() {
                  editing = false;
                });
              })
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Location Name: "),
              Text(name)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Address of Location: "),
              Text(address)
            ],
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: myController1,
                      onChanged: (String val) {
                      },
                    ),
                    TextFormField(
                      controller: myController2,
                    )
                  ],
                ),
              ),
            ),
          ),

          FlatButton(
              onPressed: () {
                setState(() {
                print(myController1.text);
                print(myController2.text);
                updateFirebase(myController1.text, myController2.text, docID);
                  editing = false;
                });
          },
              child: Text("Save")
          )
        ],
      ),
    );
  }

  void onRefresh() {
    print("Refreshing now");
    SuperListener.updateLocations();
    loadPlaces();
    refreshController.refreshCompleted();

  }


  Widget viewingPage() {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text("List of Locations"),
            ],
          ),
        ),
        body: (
        SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          child: ListView(
              children: places.isEmpty? [Text("Swipe down to refresh")] : places
              // [
              //   Text("GOYA")
              // ]
          ),
          onRefresh: onRefresh,
        )

        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return editing? editingPage(currentLoc): viewingPage();
  }
}
