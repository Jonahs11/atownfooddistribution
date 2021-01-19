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

  @override
  Widget build(BuildContext context) {
    //return Widget createCardForLocList(String key, List value) {
    return GestureDetector(
      onTap: () {
        SuperListener.createAlert(context, widget.name, widget.value[0], widget.value[3], widget.value[4], widget.value[5]);
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                  widget.name
              ),
            ),
            Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.star,
                    color: widget.favorites.contains(widget.name)? Colors.yellowAccent: Colors.grey,
                  ),
                  onPressed: () {
                    if(widget.favorites.contains(widget.name)) {
                      print("Removing");
                      setState(() {
                        widget.favorites.remove(widget.name);
                      });
                    }
                    else {
                      print("adding");
                      setState(() {
                        widget.favorites.add(widget.name);
                      });
                    }
                    SuperListener.writeToFile(widget.favorites);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
