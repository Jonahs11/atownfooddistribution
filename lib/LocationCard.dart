import 'package:flutter/material.dart';

import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';
import 'package:atownfooddistribution/Search.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';


class LocationCard extends StatefulWidget {

  final String name;
  final List value;
  final List favorites;

  const LocationCard( {Key key, this.name, this.value, this.favorites}): super(key: key);

  @override
  _LocationCardState createState() => _LocationCardState(
    name: name,
    value: value,
    favorites: favorites
  );
}

class _LocationCardState extends State<LocationCard> {
   String name;
   List value;
   List favorites;

   _LocationCardState({this.name, this.value, this.favorites});


   Future removeFavoriteConfirmation(BuildContext context) {
     return showDialog(context: context, builder: (context) {
       return AlertDialog(
         title: Text("Are you sure you would like to remove $name as a favorite?"),
         content: Row(
           children: [
             FlatButton(
                 onPressed: () {
                   if(this.mounted) {
                     setState(() {
                       favorites.remove(name);
                       SuperListener.writeToFile(favorites);
                       Navigator.of(context).pop();
                     });
                   }
                   else {
                       favorites.remove(name);
                       SuperListener.writeToFile(favorites);
                       Navigator.of(context).pop();
                   }
                 },
                 child: Text("Yes Remove $name")),
             FlatButton(
                 onPressed: () {
                   print("Keeping");
                   Navigator.of(context).pop();
                 },
                 child: Text("No cancel")),
           ],
         ),
       );
     });
   }

   Future addFavoriteConfirmation(BuildContext context) {
     return showDialog(context: context, builder: (context) {
       return AlertDialog(
         title: Text("Please confirm whether you would like to add $name as a favorite?"),
         content: Row(
           children: [
             FlatButton(
                 onPressed: () {
                   if(this.mounted) {
                     setState(() {
                       favorites.add(name);
                       SuperListener.writeToFile(favorites);
                       Navigator.of(context).pop();
                     });
                   }
                   else
                     {
                       favorites.add(name);
                       SuperListener.writeToFile(favorites);
                       Navigator.of(context).pop();
                     }

                 },
                 child: Text("Yes add $name")),
             FlatButton(
                 onPressed: () {
                   print("Keeping");
                   Navigator.of(context).pop();
                 },
                 child: Text("No cancel")),
           ],
         ),
       );
     });
   }

  @override
  Widget build(BuildContext context) {
    //return Widget createCardForLocList(String key, List value) {
    return GestureDetector(
      onTap: () {
        SuperListener.createAlert(context, name, value[0], value[3], value[4], value[5]);
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                  name
              ),
            ),
            Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.star,
                    color: favorites.contains(name)? Colors.yellowAccent: Colors.grey,
                  ),
                  onPressed: () {
                    if(favorites.contains(name)) {
                      removeFavoriteConfirmation(context);
                    }
                    else {
                      addFavoriteConfirmation(context);
                    }
                    print("File being updated");
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

