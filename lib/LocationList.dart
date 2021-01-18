//import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';
import 'package:atownfooddistribution/Search.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

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
  List favorites = [];

  Directory directory;
  File jsonFile;
  String fileName = 'favorites.json';
  bool fileExists;
  List fileContent = [];


  bool viewingLocList = true;
  bool viewingFavList = false;
  bool editingLoc = false;
  bool searchInUse = false;

  @override
  void initState() {
    SuperListener.setPages(lPage: this);
    loadInFile();
    super.initState();
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
      }

    });
  }

  void checkFavsContents() {
    for(String i in favorites) {
      print(i);
    }
  }

  List getListLocs() {
    List locationNames = [];
    locations.keys.forEach((element) {
      locationNames.add(element);
    });
    return locationNames;
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

  void createFile(List favs) {
    //File file = new File(directory.path + "/" + fileName);
    jsonFile.createSync();
    fileExists = true;
    jsonFile.writeAsStringSync(jsonEncode(favs));
  }



  Future createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes, String link){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(name),
            ),
            Expanded(child: Expanded(
              child: IconButton(icon: Icon(Icons.edit), onPressed: () {
                setState(() {
                  editing = true;
                  viewingLocList = false;
                  viewingFavList = false;
                  searchInUse = false;

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
              }),
            )),
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
      key: UniqueKey(),
      onTap: () {
        createAlertDialog(context, key, value[0], value[3], value[4], value[5]);
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                  key
              ),
            ),
            Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.star,
                    color: favorites.contains(key)? Colors.yellowAccent: Colors.grey,
                  ),
                  onPressed: () {
                   if(favorites.contains(key)) {
                     print("Removing");
                     setState(() {
                       favorites.remove(key);
                     });
                   }
                   else {
                     print("adding");
                     setState(() {
                       favorites.add(key);
                     });
                   }
                   writeToFile(favorites);
                   loadPlaces();
              }),
            ),

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
                  viewingFavList = false;
                  viewingLocList = true;

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
                mySearch.searchOpen = false;
                editing = false;
                viewingFavList = false;
                viewingLocList = true;
                });
          },
              child: Text("Save")
          )
        ],
      ),
    );
  }

  void onRefresh()   {
      SuperListener.updateLocations().then((value) => loadPlaces());
      refreshController.refreshCompleted();

  }


  Widget favoritesPage() {
    List<Widget> myFavs = [];
    for(String i in favorites) {
      Widget tempWidget = createCardForLocList(i , locations[i]);
      myFavs.add(tempWidget);
    }
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    viewingFavList = false;
                    viewingLocList = true;
                  });
                },
              ),
              Text("Favorite Locations Page"),

            ],
          ),
        ),
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
              ),
              IconButton(icon: Icon(Icons.refresh), onPressed: () {
                setState(() {
                  checkFavsContents();
                 // places.clear();
                });

              }),
              IconButton(
                  icon: Icon(Icons.star),
                  onPressed: () {
                    setState(() {
                      viewingFavList = true;
                      viewingLocList = false;
                    });
              })
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
    if(editing) {
      return editingPage(currentLoc);
    }
    else if(viewingLocList) {
      return viewingPage();
    }
    else if(viewingFavList) {
      return favoritesPage();
    }
   // return editing? editingPage(currentLoc): viewingPage();
  }
}
