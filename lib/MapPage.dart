
import 'dart:async';

import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';


//locations is a map used to take the information from the cloud fire storage database and store it onto the phone
final Map<String, List> locations = <String, List>{};

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


  //markers is a set that stores the Markers onto the Google Map
  final Set<Marker> markers = <Marker>{};


  

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    locationStream =  location.onLocationChanged.listen((event) {
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
    void checkFirebase() {
      try {
        FirebaseFirestore.instance
            .collection('markers')
            .get()
            .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          locations[doc['name']] = [doc['address'], doc['lat'], doc['long'] ,doc['foodlevel'], doc['notes'], doc['link']];
        }),
        createMarkers(markers, locations)
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
    void createMarkers(Set<Marker> markers, Map<String, List> locations) {
      Marker tempMarker;
    locations.forEach((key, value) {
      tempMarker = new Marker(
        markerId: MarkerId(key),
        position: LatLng(double.parse(value[1]), double.parse(value[2])),
        visible: true,
        draggable: false,
        onTap: () {
          createAlertDialog(context, key, value[0], value[3], value[4], value[5]);
        }
      );
      setState(() {
        markers.add(tempMarker);
      });
    });
      print("Markers have been made");
    }


    //method that return an alert dialog. This will be used when the markers are clicked on in app
    createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes, String link){
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

    void checkMarkers() {
    markers.forEach((element) {
      print(element.markerId);
      print(element.position);
      print(element.visible);
    });
    }

    void moveToMyLoc() async{

    try {
      LocationData myLoc = await location.getLocation();
      currentLat = myLoc.latitude;
      currentLong = myLoc.latitude;
      mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLat, currentLong))
      ));
    }
    catch(e)
      {
        print("Error");
      }
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
        title: cameraMovementOn? Text("Auto-Camera Movment On"): Text("Auto-Camera Movement Off")
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(40.6023, -75.4714), zoom: 16),
            onMapCreated: onMapCreated,
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: mylocationEnabled,
            markers: markers,
            // onTap: (LatLng pos) {
            //   if(cameraMovementOn) {
            //     setState(() {
            //       cameraMovementOn = false;
            //       locationStream.pause();
            //     });
            //   }
            //}

          ),

          Positioned(
              right: 10,
              bottom: 150,
              child: FloatingActionButton(
                  child: Icon(Icons.assignment_late_sharp),
                  onPressed: () {
                    SuperListener.navTo(2);
          })),
          Positioned(
            left: 10,
            bottom: 150,
            child: IconButton(
              icon: Icon(Icons.eleven_mp),
              onPressed: () {
                createMarkers(markers, locations);
              },
            )
          ),
          Positioned(
            top: 50,
              right: 5,
              child: Switch(
                value: cameraMovementOn,
                onChanged: toggleSwitchSliderTap,
                activeColor: Colors.blue,
                inactiveTrackColor: Colors.red,

              ))
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


  @override
  void initState() {
    SuperListener.setPages(mPage: this);

    initFlutterFire();
    print("LOADED IN");
    checkMap();
    //checkFirebase();
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