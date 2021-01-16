import 'package:atownfooddistribution/SuperListener.dart';
import 'package:flutter/material.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:atownfooddistribution/SuperListener.dart';

class Search extends SearchDelegate<String> {

  bool searchOpen = false;

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
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
      close(context, null);
      searchOpen = false;
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    print("ACCESSING build results");


    final List myList = query.isEmpty ?
    SuperListener().getListLocations():
    SuperListener().getListLocations().where((element) => element.toString().startsWith(query)).toList();
    return myList.isEmpty ? Center(
      child: Text("No results found..."),
    ) :
    ListView.builder(
        itemCount: myList.length,
        itemBuilder: (context, index) {
          final String listItem = myList[index];
           return SuperListener.createCard(listItem, locations[listItem]);
        });

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List myList = query.isEmpty ?
    SuperListener().getListLocations():
    SuperListener().getListLocations().where((element) => element.toString().startsWith(query)).toList();
    return myList.isEmpty?
    Center(
      child: Text("No results found...",
        style: TextStyle(
        ),
      ),
    ) : Container(
      color: Colors.grey,
      child: ListView.builder(
          itemCount: myList.length,
          itemBuilder: (context, index) {
            final String listItem = myList[index];
             return SuperListener.createCard(listItem, locations[listItem]);

          }),
    );
  }

}