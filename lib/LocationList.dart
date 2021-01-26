//import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:atownfooddistribution/LocationCard.dart';
import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';
import 'package:atownfooddistribution/Search.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

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
  bool administrator = false;
  List favorites = [];

  Directory directory;
  File jsonFile;
  String fileName = 'favorites.json';
  bool fileExists;
  List fileContent = [];


  bool viewingLocList = true;
  bool viewingFavList = false;
  bool editingLoc = false;
  bool viewingAlphaList = false;


  List<String> options = ["Alphabetical", "Distance", "Favorites"];
  String currentValue = "Distance";

  DropdownMenuItem selectedItem;

  @override
  void initState() {
    SuperListener.setPages(lPage: this);
    loadInFile();
    super.initState();
  }

  void makeAdmin() {
    setState(() {
      administrator = true;
    });
 }

  void loadInFile() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      this.directory = directory;
      jsonFile = new File(directory.path + "/" + fileName);
      fileExists = jsonFile.existsSync();

      if(fileExists) {
        this.setState(() {
          favorites = json.decode(jsonFile.readAsStringSync());
          print("Favs loaded in");
        });
      }
      else
      {
        createFile(favorites);
        print("THERE was no file but now there is!");
      }

    });
  }

  void createFile(List favs) {
    //File file = new File(directory.path + "/" + fileName);
    jsonFile.createSync();
    fileExists = true;
    //jsonFile.writeAsStringSync(jsonEncode(favs));
  }

  void checkFavsContents() {
    for(String i in favorites) {
      print(i);
    }
  }

  void moveToFavs() {
    setState(() {
      viewingLocList = false;
      editingLoc = false;
      viewingFavList = true;
    });
  }

  List getListLocs() {
    List locationNames = [];
    locations.keys.forEach((element) {
      locationNames.add(element);
    });
    return locationNames;
  }



  Future createAlertDialog(BuildContext context, String name, String address,String notes, String link, String schedule, String requirements, String phone){
    CalendarController calendarController = new CalendarController();
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(name),
            ),
            Visibility(
              visible: administrator,
              child: Expanded(child: IconButton(icon: Icon(Icons.edit), onPressed: () {
                setState(() {
                  editing = true;
                  viewingLocList = false;
                  viewingFavList = false;

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
              })),
            ),
            SizedBox(
              width: 40.0,
            ),
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
            Row(children: [
              Expanded(
                child: FlatButton(
                    onPressed: () {
                      launch(link);
                    },
                    child: Text("Address: $address\n",
                      style: TextStyle(
                          color: Colors.blueAccent
                      )
                      ,)),
              )
            ],),
            Text("Additional Notes: $notes\n"),
            Text("Hours of Operation: $schedule"),
            Text("Requirements to be served: $requirements\n"),
            Row(
                children: [
                  Text("Phone Number: "),
                  FlatButton(onPressed:() {
                    setState(() {
                      makePhoneCall('tel:$phone');
                    });
                  } ,
                      child: Text(phone,
                        style: TextStyle(
                            color: Colors.blueAccent
                        ),))
                ]
            ),
            // Container(
            //   width: 100,
            //   height: 100,
            //     child: TableCalendar(
            //         calendarController: calendarController))
          ],
        ),
      );
    } );
  }


  void writeToFile(List favs) {
    print("Writing to file");
    if(fileExists) {
      print("File exists");
      jsonFile.writeAsStringSync(jsonEncode(favs));
    }
    else {
      print("Creating new file");
      createFile(favs);
    }
  }


  Future<void> makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
    else {
      throw 'Could not lauch url';
    }
  }


  void loadPlacesByDistance() {
    places.clear();
    Widget tempWidget;
    double distance;
    List nameDist = [];
    List tempTuple = [];

    locations.forEach((key, value) {
      distance = value[6];
      tempTuple = [key, distance];
      nameDist.add(tempTuple);
    });
    bool noChanges = true;
    do {
      noChanges = true;
      for (int i = 0; i < nameDist.length - 1; i++) {
        if (nameDist[i][1] > nameDist[i + 1][1]) {
          tempTuple = nameDist[i];
          nameDist[i] = nameDist[i + 1];
          nameDist[i + 1] = tempTuple;
          noChanges = false;
        }
      }
    } while (!noChanges);

    for (int k = 0; k < nameDist.length; k++) {
      print(locations[nameDist[k][0]][4]);
      tempWidget = LocationCard(key: UniqueKey(), name: nameDist[k][0], value: locations[nameDist[k][0]], favorites: favorites);
      setState(() {
        print(nameDist[k][0]);
        print("^^^");
        places.add(tempWidget);
      });
    }
  }

  loadPlacesAlphabetically() {
    setState(() {
      LocationCard temp = places[1];
      places[1] = places[0];
      places[0] = temp;
    });
  }

  double getDistance(double lat1, double long1, double lat2, double long2) {
    double dist = distance.distance(LatLng(lat1, long1), LatLng(lat2, long2));
    print(dist);
    return dist;
  }

  void updateFirebase(String notes, String id) {
    SuperListener.updateFirebase(notes, id);
  }

  Widget editingPage(String key) {
    String name = key;
    String address = locations[key][0];
    String notes = locations[key][3];
    String docID = locations[key][5];

    TextEditingController myController1 =
        new TextEditingController(text: notes);


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
                  viewingFavList = false;
                  viewingLocList = true;

                });
              })
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text("Location Name: "), Text(name)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text("Address of Location: "), Text(address)],
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
                    )
                  ],
                ),
              ),
            ),
          ),
          FlatButton(
              onPressed: () {
                setState(() {
                updateFirebase(myController1.text,  docID);
                SuperListener.updateLocations();
                mySearch.searchOpen = false;
                editing = false;
                viewingFavList = false;
                viewingLocList = true;
                });
              },
              child: Text("Save"))
        ],
      ),
    );
  }

  // void onRefresh() {
  //   SuperListener.updateLocations().then((value) => loadPlaces());
  //   refreshController.refreshCompleted();
  // }


  void onRefresh()  {
      SuperListener.updateLocations().then((value) => loadPlacesByDistance());
      refreshController.refreshCompleted();

  }


  Widget favoritesPage() {
    List<Widget> myFavs = [];
    for(String i in favorites) {
      Widget tempWidget = LocationCard(key: UniqueKey(), name: i, value: locations[i], favorites: favorites,);
      myFavs.add(tempWidget);
    }
    return Scaffold(
        appBar: locListAppBar(),
        body: (
            SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              child: ListView(
                  children: myFavs.isEmpty? [Text("You have selected no favorites")] : myFavs
              ),
              onRefresh: onRefresh,
            )
        )
    );
  }

  Widget alphaPage() {
    List nameList = [];
    for(LocationCard i in places) {
      nameList.add(i.name);
    }

    nameList.sort();
    List<LocationCard> alphaPlaces = [];
    for(String i in nameList) {
      Widget tempWidget = LocationCard(key: UniqueKey(), name: i, value: locations[i], favorites: favorites,);
      alphaPlaces.add(tempWidget);
    }
    return Scaffold(
        appBar: locListAppBar(),
        body: (
            SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              child: ListView(
                  children: alphaPlaces
              ),
              onRefresh: onRefresh,
            )
        )
    );
  }

  Widget distancePage() {
    return Scaffold(
        appBar: locListAppBar(),
        body:
            SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              child: ListView(
                  children: places.isEmpty? [Text("Swipe down to refresh")] : places
              ),
              onRefresh: onRefresh,
            )
        );
  }

  AppBar locListAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Sort By: "),
          DropdownButton<String>(
            value: currentValue,
            items: options.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (String newItemChoice) {
              newOrderedValueSelected(newItemChoice);
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: mySearch);
            },
          ),
        ],
      ),
    );
  }

  newOrderedValueSelected(String choice) {
    if(choice != currentValue) {
      setState(() {
        currentValue = choice;

        if(currentValue == "Favorites") {
          viewingLocList = false;
          viewingAlphaList = false;
          viewingFavList = true;
        }
        else if(currentValue == "Alphabetical") {
          viewingLocList = false;
          viewingFavList = false;
          viewingAlphaList = true;
        }
        else if(currentValue == "Distance") {
          viewingFavList = false;
          viewingAlphaList = false;
          viewingLocList = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(editing) {
      return editingPage(currentLoc);
    }
    else if(viewingLocList) {
      return distancePage();
    }
    else if(viewingFavList) {
      return favoritesPage();
    }
    else if(viewingAlphaList) {
      return alphaPage();
    }
  }
}

