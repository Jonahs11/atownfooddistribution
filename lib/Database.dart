// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
//
// class Database extends StatefulWidget {
//   @override
//   _DatabaseState createState() => _DatabaseState();
// }
//
// class _DatabaseState extends State<Database> {
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference markers = FirebaseFirestore.instance.collection('markers');
//     return FutureBuilder(
//         future: markers.doc("diLPwNP"),
//         builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.hasError) {
//             // ignore: missing_return
//             return Text("ERROR");
//           }
//           if (snapshot.connectionState == ConnectionState.done) {
//             Map<String, dynamic> data = snapshot.data.data();
//             return Text();
//           }
//           return Text("Loading....");
//         });
//   }
// }

