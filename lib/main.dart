import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CameraPosition _center = CameraPosition(target: LatLng(-45.71, 75));
  Location location = new Location();
  GoogleMapController mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(event.latitude, event.longitude))
      ));
    }
    );


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: GoogleMap(
          initialCameraPosition: _center,
          onMapCreated: onMapCreated,
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,

        )
    );
  }
}
