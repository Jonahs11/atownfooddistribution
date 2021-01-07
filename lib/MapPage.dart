import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  CameraPosition _center = CameraPosition(target: LatLng(-45.71, 75));
  Location location = new Location();
  GoogleMapController mapController;
  //double currentZoom = 15.0;
  bool tracking = true;
  double currentSliderVal = 15.0;

  bool appInitialized = false;



//  final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  
  // // MarkerId markerId1 = new MarkerId("1");
  // Marker marker1 = new Marker(
  //   markerId: MarkerId("1"),
  //   position: LatLng(40.5975, -75.5),
  //   visible: true,
  //   draggable: false,
  //   );

  final Set<Marker> markers = <Marker>{};
  final Map<String, List> locations = <String, List>{};

  

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) {
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

    void initFlutterFire() async {
      try {
        await  Firebase.initializeApp();
        setState(() {
          appInitialized = true;
        });
      }
      catch (e) {
        print(e.toString());
      }
    }

    void checkFirebase() {
      try {
        FirebaseFirestore.instance
            .collection('markers')
            .get()
            .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          locations[doc['name']] = [doc['address'], doc['lat'], doc['long'] ,doc['foodlevel'], doc['notes']];
        })
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


    Marker addMarkerFunc(Marker marker, String name, String address, String amountFood)
    {
      marker = new Marker(
          markerId: MarkerId("1"),
          position: LatLng(40.5975, -75.5),
          visible: true,
          draggable: false,
          onTap: () {
            setState(() {
              createAlertDialog(context, name, address, amountFood);
              print("Hello World");
            });
          });
      return marker;

    }

    void checkMap() {
    locations.forEach((key, value) {
      print(key);
      value.forEach((element) {
        print(element);
      });
    });
    }

    //value list goes [address, lat, long, foodlevel, notes]
    void createMarkers(Set<Marker> markers, Map<String, List> locations) {
      Marker tempMarker;
    locations.forEach((key, value) {
      tempMarker = new Marker(
        markerId: MarkerId(key),
        position: LatLng(double.parse(value[1]), double.parse(value[2])),
        visible: true,
        draggable: false,
        onTap: () {
          createAlertDialog(context, key, value[0], value[3]);
          print("Markers have been made");
        }
      );
      markers.add(tempMarker);
    });

    }


    createAlertDialog(BuildContext context, String name, String address, String amountFood){
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


  Widget mapPage() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _center,
          onMapCreated: onMapCreated,
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: markers,
        ),
        Positioned(
            bottom: 10.0,
            left: 5.0,
            child: Slider(
                value: currentSliderVal,
                min: 0,
                max: 50,

                onChanged: (double val) {
                  setState(() {
                    currentSliderVal = val;
                    //currentZoom = val /2;
                  });
                })),
        Positioned(
            top: 10,
            left: 10,
            child: IconButton(
                icon: Icon(Icons.adb_outlined),
                onPressed: () {
          checkFirebase();
        })),
        Positioned(
            top: 50,
            left: 10,
            child: IconButton(
                icon: Icon(Icons.adb_outlined),
                onPressed: () {
                  setState(() {
                    createMarkers(markers, locations);
                    //checkMarkers();
                  });

                })),
      ],
    );
  }

  Widget errorPage() {
    return Scaffold(
      body: Text("Something went wrong"),
    );
  }


  @override
  void initState() {
    // marker1 = addMarkerFunc(marker1, "Ritas", "2400 Chew Street, Allentown PA", "High");
    // markers[marker1.markerId] = marker1;
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
