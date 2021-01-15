//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';
import 'package:atownfooddistribution/Search.dart';

Search mySearch = Search();

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
  List<Widget> sortedPlaces = [];

  @override
  void initState() {
    SuperListener.setPages(lPage: this);
    super.initState();
  }

  List getListLocs() {
    List locationNames = [];
    locations.keys.forEach((element) {
      locationNames.add(element);
    });
    return locationNames;
  }


  Future createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes, String link){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Row(
              children: [
                Text(name,
                  style: TextStyle(
                      fontSize: 40.0
                  ),),
                IconButton(icon: Icon(Icons.edit), onPressed: () {
                  setState(() {
                    editing = true;
                     Navigator.of(context).pop();
                     try{
                       if(mySearch.searchOpen) {
                         mySearch.close(context, null);
                       }
                     }
                     catch(e) {
                       print("Error With Search");
                     }

                    currentLoc = name;

                  });
                })
              ],
            ),),
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

  Widget createCardForLocList(String key, List value) {
    return GestureDetector(
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
            // IconButton(icon: Icon(Icons.edit), onPressed: () {
            //   print("Editing $key");
            //   setState(() {
            //     currentLoc = key;
            //     editing = true;
            //   });
            // }),
            Text(value[7].toString()),

          ],
        ),
      ),
    );
  }

  void loadPlaces() {
    places.clear();
    Widget tempWidget;
    double distance;
    List nameDist = [];
    List tempTuple = [];

    locations.forEach((key, value)
    {

      distance = value[7];
      tempTuple = [key, distance];
      nameDist.add(tempTuple);

    });
    bool noChanges = true;
    do {
      noChanges = true;
      for(int i = 0; i < nameDist.length - 1; i++) {

        if(nameDist[i][1] > nameDist[i+1][1]) {
          tempTuple = nameDist[i];
          nameDist[i] = nameDist[i+1];
          nameDist[i+1] = tempTuple;
          noChanges = false;
        }
      }
    }
    while(!noChanges);

    for(int k= 0; k < nameDist.length; k++) {
      print(locations[nameDist[k][0]][4]);
      tempWidget = createCardForLocList(nameDist[k][0], locations[nameDist[k][0]]);
      setState(() {
        places.add(tempWidget);
      });
    }

  }

  double getDistance(double lat1, double long1, double lat2, double long2) {
    double dist = distance.distance(LatLng(lat1, long1), LatLng(lat2, long2));
    print(dist);
    return dist;
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
                  mySearch.searchOpen = false;
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
                updateFirebase(myController1.text, myController2.text, docID);
                SuperListener.updateLocations();
                  editing = false;
                  mySearch.searchOpen = false;
                });
          },
              child: Text("Save")
          )
        ],
      ),
    );
  }

  void onRefresh()   {
      SuperListener.updateLocations();
      loadPlaces();
      refreshController.refreshCompleted();

  }


  Widget viewingPage() {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("List of Locations"),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: mySearch);
                },
              )
            ],
          ),
        ),
        body: (
        SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          child: ListView(
              children: places.isEmpty? [Text("Swipe down to refresh")] : places
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
