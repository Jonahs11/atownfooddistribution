import 'dart:async';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atownfooddistribution/CalendarPage.dart';




//locations is a map used to take the information from the cloud fire storage database and store it onto the phone
 Map<String, List> locations = <String, List>{};

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
  bool appInitialized = false;
  bool cameraMovementOn = false;
  DateTime now = new DateTime.now();
  GestureDetector gestureDetector = new GestureDetector();

  //List weeklyReps = [];


  //markers is a set that stores the Markers onto the Google Map
  final Set<Marker> markers = <Marker>{};


  

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    locationStream =  location.onLocationChanged.listen((event) {

     // print("$currentLat is the lat and $currentLong is the long");
      mapController.animateCamera( CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(event.latitude, event.longitude),
            zoom: 16.0,
          )
      ));
    }
    );
    locationStream.pause();
    }





    //method used to initialize the database. This is necissary in order to pull anything from it
    void initFlutterFire() async {
      try {
        await  Firebase.initializeApp();
        setState(() {
          appInitialized = true;
        });
        checkFirebase();
      }
      catch (e) {
        print(e.toString());
      }
    }

    //method used to extract all the inforamtion from the database and store it in a map to be used to populate markers on the map
    Future<void> checkFirebase() async {
    Location location = new Location();
    LocationData currentLoc =  await location.getLocation();
    double distance;
      try {
         FirebaseFirestore.instance
            .collection('markers')
            .get()
            .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          distance = SuperListener.calcDistance(currentLoc.latitude, currentLoc.longitude, double.parse(doc["lat"]), double.parse(doc["long"]));

          locations[doc['name']] = [doc['address'], doc['lat'], doc['long'] ,doc['foodlevel'], doc['notes'], doc['link'], doc.id, distance, doc['schedule'], doc['requirements'], doc['phone']];
          print("LOC Updated");
          if(doc['weekly'] == 'true') {
            List days = [];
            for(int i = 0; i < doc["day"].length; i += 2) {
              days.add(int.parse(doc["day"][i]));
              print(doc["day"][i]);
            }
            weeklyRepeats.add([doc['name'], days]);

          }

          else if(doc['periodic'] == 'true') {
            List repeatsOn = [];
            int dayOfWeek;

            for(int k = 0; k < doc["repeatson"].length; k += 2){
              repeatsOn.add(int.parse(doc["repeatson"][k]));
            }
            dayOfWeek = int.parse(doc['day']);
            periodicRepeats.add([doc['name'], repeatsOn, dayOfWeek]);
            print("A periodic day has been added");
          }
        }),
          markers.clear(),
          createMarkers(markers),

        });

      }
    catch(e)
  {
    print(e);
  }
  finally{

          print("Completed");
      }
    }


  //method used to check what is currently being stored in the locations map
    void checkMap() {
    locations.forEach((key, value) {
      print(key);
      value.forEach((element) {
        print(element);
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
        position: LatLng(double.parse(value[1]), double.parse(value[2])),
        visible: true,
        draggable: false,
        onTap: () {
          createAlertDialog(context, key, value[0], value[3], value[4], value[5], value[8], value[9], value[10]);
        }
      );
      setState(() {
        markers.add(tempMarker);
      });
    });
      print("Markers have been made");
    }


    //method that return an alert dialog. This will be used when the markers are clicked on in app
     Future createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes, String link, String schedule, String requirements, String phone){
        return showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(name),
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
                Text("Current amount of food: $amountFood\n"),
                Text("Additional Notes: $notes\n"),
                Text("Hours of Operation: $schedule"),
                Text("Requirements to be served: $requirements\n"),
                Row(
                    children: [
                      Text("Phone Number: "),
                      FlatButton(onPressed:() {
                        setState(() {
                          SuperListener.makePhoneCall('tel:$phone');
                        });
                      } ,
                          child: Text(phone,
                            style: TextStyle(
                                color: Colors.blueAccent
                            ),))
                    ]
                ),
              ],
            ),
          );
        } );
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
    if(cameraMovementOn) {
      setState(() {
        cameraMovementOn = false;
        locationStream.pause();
      });

    }
    else {
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
        backgroundColor: cameraMovementOn? Colors.blue: Colors.red,
        title: Column(
          children: [
            cameraMovementOn? Text("Auto-Camera Movment On"): Text("Auto-Camera Movement Off"),
            Text("Map last updated on " + now.toString(),
            style: TextStyle(
              fontSize: 10.0,
            ),)
          ],
        )
      ),
      body: Stack(
        children: [
          GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(40.6023, -75.4714), zoom: 12),
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
              checkFirebase();
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

  launchURL(String url) async{
    print(url);
    if(await canLaunch(url)) {
      await launchURL(url);
    }
    else {
      throw 'Could not launch $url';
    }
  }

  void updateFirebase(String foodLevel, String notes, String id) {
    try {
      print(id);
      FirebaseFirestore.instance.collection('markers').doc(id).
      update({'notes': notes, 'foodlevel': foodLevel}).then((value) {
        print("Success");
      });
    }
    catch(e) {
      print("THERE WAS AN ERROR");
    }
  }

  @override
  void initState() {
    SuperListener.setPages(mPage: this);
    initFlutterFire();
    checkMap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (appInitialized) {
      return mapPage();
    }
    else {
      return errorPage();
    }
  }
}
