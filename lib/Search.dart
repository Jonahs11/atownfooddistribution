import 'package:atownfooddistribution/SuperListener.dart';
import 'package:flutter/material.dart';

class Search extends SearchDelegate<String> {




  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () {
        query = "";
    })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
      close(context, null);
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
          return ListTile(
            onTap: () {
              showResults(context);
            },
            title: Text(listItem),);
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
    ) : ListView.builder(
        itemCount: myList.length,
        itemBuilder: (context, index) {
          final String listItem = myList[index];
          return ListTile(
            onTap: () {
              showResults(context);
            },
            title: Text(listItem),);
        });
  }

}