import 'dart:async';
import 'package:allentownfooddist/SuperListener.dart';
import 'package:allentownfooddist/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allentownfooddist/CalendarPage.dart';

//locations is a map used to take the information from the cloud fire storage database and store it onto the phone
Map<String, Map> locations = <String, Map>{};

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  // CameraPosition _center = CameraPosition(target: LatLng(-45.71, 75), zoom: currentZoom);
  Location location = new Location();
  StreamSubscription<LocationData> locationStream;
  GoogleMapController mapController;
  double currentZoom = 15.0;
  bool tracking = true;
  double currentSliderVal = 15.0;
  double currentLat;
  double currentLong;
  final mylocationEnabled = true;
  bool cameraMovementOn = false;
  DateTime now = new DateTime.now();
  GestureDetector gestureDetector = new GestureDetector();

  //List weeklyReps = [];

  //markers is a set that stores the Markers onto the Google Map
  final Set<Marker> markers = <Marker>{};

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    locationStream = location.onLocationChanged.listen((event) {
      // print("$currentLat is the lat and $currentLong is the long");
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(event.latitude, event.longitude),
        zoom: 16.0,
      )));
    });
    locationStream.pause();
  }

  //method used to initialize the database. This is necissary in order to pull anything from it
  // void initFlutterFire() async {
  //   try {
  //     // FirebaseFirestore.instance
  //     //     .collection('markers')
  //     //     .get()
  //     //     .then((QuerySnapshot querySnapshot) => {
  //     //           querySnapshot.docs.forEach((doc) {
  //     //             print(doc['name']);
  //     //           })
  //     //         });
  //     setState(() {
  //       appInitialized = true;
  //     });
  //     checkFirebase();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  //method used to extract all the inforamtion from the database and store it in a map to be used to populate markers on the map
  Future<void> checkFirebase() async {
    Location location = new Location();
    LocationData currentLoc = await location.getLocation();
    double distance;
    try {
      FirebaseFirestore.instance
          .collection('markers')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  try {
                    distance = SuperListener.calcDistance(
                        currentLoc.latitude,
                        currentLoc.longitude,
                        double.parse(doc["lat"]),
                        double.parse(doc["long"]));

                    // if (doc['name'] == "Allentown Salvation Army") {
                    //   locations[doc['name']] = {
                    //     "address": doc['address'],
                    //     "lat": doc['lat'],
                    //     "long": doc['long'],
                    //     "notes": doc['notes'],
                    //     "link": doc['link'],
                    //     "id": doc.id,
                    //     "distance": distance,
                    //     "requirements": doc['requirements'],
                    //     "phone": doc['phone'],
                    //     "firsthours": doc["first"],
                    //     "secondhours": doc['second'],
                    //     "thirdhours": doc['third'],
                    //     "firstwritten": doc['firstwritten'],
                    //     "secondwritten": doc["secondwritten"],
                    //     "thirdwritten": doc["thirdwritten"],
                    //     "schedule": doc["schedule"]
                    //   };
                    //
                    //   print("Salvation army added");
                    //   weeklyRepeats.add([
                    //     doc['name'],
                    //     [1, 3]
                    //   ]);
                    //   periodicRepeats.add([
                    //     doc['name'],
                    //     [2, 4],
                    //     3
                    //   ]);
                    // }

                    locations[doc['name']] = {
                      "address": doc['address'],
                      "lat": doc['lat'],
                      "long": doc['long'],
                      "notes": doc['notes'],
                      "link": doc['link'],
                      "id": doc.id,
                      "distance": distance,
                      "schedule": doc['schedule'],
                      "requirements": doc['requirements'],
                      "phone": doc['phone'],
                      "type": doc['type'],
                      "writtenSched": doc["writtendays"]
                    };
                    if (doc['weekly'] == 'TRUE') {
                      List days = [];
                      for (int i = 0; i < doc["day"].length; i += 2) {
                        days.add(int.parse(doc["day"][i]));
                        print(doc["day"][i]);
                      }
                      weeklyRepeats.add([doc['name'], days]);
                    } else if (doc['periodic'] == 'TRUE') {
                      List repeatsOn = [];
                      int dayOfWeek;

                      for (int k = 0; k < doc["repeatson"].length; k += 2) {
                        repeatsOn.add(int.parse(doc["repeatson"][k]));
                      }
                      dayOfWeek = int.parse(doc['day']);
                      periodicRepeats.add([doc['name'], repeatsOn, dayOfWeek]);
                      print("A periodic day has been added");
                    }
                    //            else {
                    //   print("Adding Grace Community Foundation");
                    //   weeklyRepeats.add([
                    //     "Grace Community Foundation",
                    //     [5]
                    //   ]);
                    //   periodicRepeats.add([
                    //     "Grace Community Foundation",
                    //     [3],
                    //     6
                    //   ]);
                    // }
                  } catch (e) {
                    print("There has been an error loading in ${doc['name']}");
                  }
                }),
                markers.clear(),
                createMarkers(markers),
              });
    } catch (e) {
      print(e);
    } finally {
      print("Completed");
    }
  }

  //method used to check what is currently being stored in the locations map
  void checkMap() {
    locations.forEach((key, value) {
      print(key);
      value.forEach((key, value) {
        print(key + " " + value);
      });
    });
  }

  //value list goes [address, lat, long, foodlevel, notes]
  //method used to create all the Markers and populate the markers set with Markers
  void createMarkers(Set<Marker> markers) {
    Marker tempMarker;
    locations.forEach((key, value) {
      tempMarker = new Marker(
          markerId: MarkerId(key),
          position:
              LatLng(double.parse(value["lat"]), double.parse(value["long"])),
          visible: true,
          draggable: false,
          onTap: () {
            SuperListener.makeAlert(context, key, value, false, true);
          });
      setState(() {
        markers.add(tempMarker);
      });
    });
    print("Markers have been made");
  }

  void checkMarkers() {
    markers.forEach((element) {
      print(element.markerId);
      print(element.position);
      print(element.visible);
    });
  }

  void toggleSwitchSliderTap(bool val) {
    print(cameraMovementOn);
    if (cameraMovementOn) {
      setState(() {
        cameraMovementOn = false;
        locationStream.pause();
      });
    } else {
      setState(() {
        cameraMovementOn = true;
        locationStream.resume();
      });
    }
    print(cameraMovementOn);
  }

  //this method returns the standard map screen, and is what the users will see
  //if there is not a problem while loading into the app
  Widget mapPage() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: cameraMovementOn ? Colors.blue : Colors.red,
          title: Column(
            children: [
              cameraMovementOn
                  ? Text("Auto-Camera Movment On")
                  : Text("Auto-Camera Movement Off"),
              Text(
                "Map last updated on " + now.toString(),
                style: TextStyle(
                  fontSize: 10.0,
                ),
              )
            ],
          )),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(40.6023, -75.4714), zoom: 12),
            onMapCreated: onMapCreated,
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: mylocationEnabled,
            markers: markers,
          ),
          Positioned(
              top: 50,
              right: 5,
              child: Switch(
                value: cameraMovementOn,
                onChanged: toggleSwitchSliderTap,
                activeColor: Colors.blue,
                inactiveTrackColor: Colors.red,
              )),
          Positioned(
              top: 100.0,
              left: 5.0,
              child: Container(
                color: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    //checkFirebase();
                    setState(() {
                      now = new DateTime.now();
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  //error page thrown when there was an issue loading into the app
  Widget errorPage() {
    return Scaffold(
      body: Text("Something went wrong"),
    );
  }

  launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launchURL(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void updateFirebase(String notes, String id) {
    try {
      print(id);
      FirebaseFirestore.instance
          .collection('markers')
          .doc(id)
          .update({'notes': notes}).then((value) {
        print("Success");
      });
    } catch (e) {
      print("THERE WAS AN ERROR");
    }
  }

  @override
  void initState() {
    SuperListener.setPages(mPage: this);
    checkFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mapPage();
  }
}
