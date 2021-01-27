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
      appBar: AppBar(
        title: Text("Information Page"),
      ),
      body: Column(
        children: [
          SizedBox( height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text("The purpose of this app is to help residents of the Allentown area navigate to sites who are serving food.")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text("\n\nThe app utilizes three main screens to try and make the information as easily accessible as possible.")),

            ],
          ),
        ],
      ),
    );
  }
}
