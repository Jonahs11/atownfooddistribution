import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  void loadPlaces() {
    //List<Widget> containers = [];
    Card tempCard;
    //widget.myLocs.forEach((key, value)
    locations.forEach((key, value)
    {
      tempCard = Card(
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
      );
      setState(() {
        places.add(tempCard);
      });
    });

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
              // IconButton(icon: Icon(Icons.close), onPressed: () {
              //   SuperListener.removeListLocScreen();
              // })
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
