import 'package:distfoodapp/SuperListener.dart';
import 'package:flutter/material.dart';
import 'package:distfoodapp/MapPage.dart';
import 'package:distfoodapp/SuperListener.dart';
import 'package:distfoodapp/LocationCard.dart';

class Search extends SearchDelegate<String> {
  bool searchOpen = false;
  List favs = SuperListener.getFavs();
  //bool addedOrRemovedFav = false;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      //   IconButton(icon: Icon(Icons.clear), onPressed: () {
      //     query = "";
      // })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    searchOpen = true;
    print("The Search is now open!");
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
          searchOpen = false;
          //SuperListener.moveToFavs();
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    print("ACCESSING build results");

    final List myList = query.isEmpty
        ? SuperListener().getListLocations()
        : SuperListener()
            .getListLocations()
            .where((element) => element
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()))
            .toList();
    return myList.isEmpty
        ? Center(
            child: Text("No results found..."),
          )
        : ListView.builder(
            itemCount: myList.length,
            itemBuilder: (context, index) {
              final String listItem = myList[index];
              return LocationCard(
                key: UniqueKey(),
                name: listItem,
                value: locations[listItem],
                favorites: favs,
              );
            });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List myList = query.isEmpty
        ? SuperListener().getListLocations()
        : SuperListener()
            .getListLocations()
            .where((element) => element.toString().startsWith(query))
            .toList();
    return myList.isEmpty
        ? Center(
            child: Text(
              "No results found...",
              style: TextStyle(),
            ),
          )
        : Container(
            color: Colors.grey,
            child: ListView.builder(
                itemCount: myList.length,
                itemBuilder: (context, index) {
                  final String listItem = myList[index];
                  return LocationCard(
                    key: UniqueKey(),
                    name: listItem,
                    value: locations[listItem],
                    favorites: favs,
                  );
                }),
          );
  }
}
