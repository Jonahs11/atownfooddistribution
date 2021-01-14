import 'package:atownfooddistribution/SuperListener.dart';
import 'package:flutter/material.dart';

class Search extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () {

    })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () {

    });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final myList = SuperListener().getListLocations();
    return ListView.builder(
        itemCount: myList.length,
        itemBuilder: (context, index) {
          final String listItem = myList[index];
          return ListTile(title: Text(listItem),);
        });
  }

}