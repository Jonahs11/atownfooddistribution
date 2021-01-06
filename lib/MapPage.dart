import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  CameraPosition _center = CameraPosition(target: LatLng(-45.71, 75));
  Location location = new Location();
  GoogleMapController mapController;
  double currentZoom = 15.0;

  double currentSliderVal = 15.0;

  //Function called when GoogleMap is implemented which, upon consent, tracks the user
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    location.onLocationChanged.listen((event) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(event.latitude, event.longitude), zoom: currentZoom )
      ));
    }
    );
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
                      currentZoom = val /2;
                  });
                }))

      ],
    );
  }
}
