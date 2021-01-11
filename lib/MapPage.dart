
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {

 // CameraPosition _center = CameraPosition(target: LatLng(-45.71, 75), zoom: currentZoom);
  Location location = new Location();
  GoogleMapController mapController;
  double currentZoom = 15.0;
  bool tracking = true;
  double currentSliderVal = 15.0;
  double currentLat;
  double currentLong;

  bool appInitialized = false;

  //markers is a set that stores the Markers onto the Google Map
  final Set<Marker> markers = <Marker>{};
  //locations is a map used to take the information from the cloud fire storage database and store it onto the phone
  final Map<String, List> locations = <String, List>{};

  

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;


      // location.onLocationChanged.listen((event) {
      //   mapController.animateCamera( CameraUpdate.newCameraPosition(
      //       CameraPosition(
      //         target: LatLng(event.latitude, event.longitude),
      //
      //       )
      //   ));
      // }
    //  );
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
    Marker tempMarker;
    String name;
    String address;
    double lat;
    double long;
    String foodLevel;
    String notes;
      try {
        FirebaseFirestore.instance
            .collection('markers')
            .get()
            .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
           // name = doc['name'];
           // address = doc['address'];
           // lat = double.parse(doc['lat']);
           // long = double.parse(doc['long']);
           // foodLevel = doc['foodlevel'];
           // notes = doc['notes'];
           //
           //
           // tempMarker = new Marker(
           //   markerId: MarkerId(name),
           //   position: LatLng(lat, long),
           //   visible: true,
           //   draggable: false,
           //   onTap: () {
           //     setState(() {
           //       createAlertDialog(context, name, address, foodLevel, notes);
           //     });
           //   }
           //
           // );
           //
           // print(tempMarker.position);
           // print(tempMarker.markerId);
           // print(tempMarker.visible);
           // print(tempMarker.draggable);
           //
           // setState(() {
           //   markers.add(tempMarker);
           // });

          locations[doc['name']] = [doc['address'], doc['lat'], doc['long'] ,doc['foodlevel'], doc['notes']];
        }),
        createMarkers(markers, locations)
        });


        print("THIS LINE HAS BEEN READ");
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
          createAlertDialog(context, key, value[0], value[3], value[4]);
        }
      );
      setState(() {
        markers.add(tempMarker);
      });
    });
      print("Markers have been made");
    }


    //method that return an alert dialog. This will be used when the markers are clicked on in app
    createAlertDialog(BuildContext context, String name, String address, String amountFood, String notes){
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
                Text(notes)
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

    //this method returns the standard map screen, and is what the users will see
  //if there is not a problem while loading into the app
  Widget mapPage() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(40.6023, -75.4714), zoom: 13),
          onMapCreated: onMapCreated,
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: markers,

        ),
        // Positioned(
        //     bottom: 10.0,
        //     left: 5.0,
        //     child: Slider(
        //         value: currentSliderVal,
        //         min: 0,
        //         max: 50,
        //
        //         onChanged: (double val) {
        //           setState(() {
        //             currentSliderVal = val;
        //             currentZoom = val /2;
        //             mapController.moveCamera(CameraUpdate.newCameraPosition( CameraPosition(zoom: currentZoom)));
        //           });
        //         })),
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
        )
      ],
    );
  }

  //error page thrown when there was an issue loading into the app
  Widget errorPage() {
    return Scaffold(
      body: Text("Something went wrong"),
    );
  }


  @override
  void initState() {
    SuperListener.setPages(mPage: this);

    initFlutterFire();
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
