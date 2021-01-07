import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  
  // MarkerId markerId1 = new MarkerId("1");
  Marker marker1 = new Marker(
    markerId: MarkerId("1"),
    position: LatLng(40.5975, -75.5),
    visible: true,
    draggable: false,
    );

  

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

    void checkFirebase() {
      try {

        Future<QuerySnapshot> query = FirebaseFirestore.instance
            .collectionGroup("markers").get();
        query.then((value) {
          value.docs.forEach((element) {
            print(element.data());
          });
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



  // Future<bool> changeSettings({
  //   LocationAccuracy accuracy = LocationAccuracy.high,
  //   int interval = 1000,
  //   double distanceFilter = 0,
  // }) {
  //   return LocationPlatform.instance.changeSettings(
  //     accuracy: accuracy,
  //     interval: interval,
  //     distanceFilter: distanceFilter,
  //   );
  // }


  @override
  void initState() {
    marker1 = addMarkerFunc(marker1, "Ritas", "2400 Chew Street, Allentown PA", "High");
    markers[marker1.markerId] = marker1;
    checkFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _center,
          onMapCreated: onMapCreated,
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(markers.values),
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


      ],
    );
  }
}
