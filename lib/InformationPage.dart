import 'package:flutter/material.dart';
import 'package:atownfooddistribution/SuperListener.dart';

class InformationPage extends StatefulWidget {
  @override
  InformationPageState createState() => InformationPageState();
}

class InformationPageState extends State<InformationPage> {
  @override
  void initState() {
    SuperListener.setPages(iPage: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [

            ],
          ),
          Text("Information Page!")
        ],
      ),
    );
  }
}
