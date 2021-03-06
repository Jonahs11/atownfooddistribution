import 'package:flutter/material.dart';
import 'package:distfoodapp/main.dart';
import 'package:distfoodapp/SuperListener.dart';
import 'package:distfoodapp/MapPage.dart';
import 'package:distfoodapp/LocationList.dart';
import 'package:location/location.dart';
import 'decorationInfo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool locListUp = false;
  bool adminLogging = false;
  bool administrator = false;
  //LocationList locationList = new LocationList();

  TextEditingController adminUsername = new TextEditingController();
  TextEditingController adminPassword = new TextEditingController();

  Map<String, String> adminInfo;

  @override
  void initState() {
    super.initState();
    SuperListener.setPages(wScreen: this);
    getAdminInfo();
  }

  void getAdminInfo() {
    adminInfo = new Map<String, String>();
    FirebaseFirestore.instance.collection('credentials').get().then(
          (snapshot) => {
            snapshot.docs.forEach((doc) {
              adminInfo[doc.get('username')] = doc.get('password');
            })
          },
        );
  }

  bool checkAdminCredentials(String username, String password) {
    return adminInfo.containsKey(username) && adminInfo[username] == password;
  }

  Widget welcomeScreen() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome!\n"
                  "",
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Center(
                    child: Text(
                      "If you would like to change any of the information reguarding one of the locations, use an administrator login",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 150,
            ),
            FlatButton(
              color: Colors.deepPurple,
              onPressed: () {
                setState(() {
                  adminLogging = !adminLogging;
                });
              },
              child: Text(
                'Administrator Login',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Visibility(
              visible: adminLogging,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: adminUsername,
                          decoration: DecorationInfo.kTextFieldDecoration(
                              hintText: 'Username'),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          controller: adminPassword,
                          decoration: DecorationInfo.kTextFieldDecoration(
                              hintText: 'Password'),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        FlatButton(
                          color: Colors.green[700],
                          onPressed: () async {
                            try {
                              UserCredential userCred = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: adminUsername.text,
                                      password: adminPassword.text);
                              print("Signed in");
                              administrator = true;
                              adminLogging = false;
                              SuperListener.makeAdmin();
                            } on FirebaseAuthException catch (e) {
                              if (e.code == "user-not-found") {
                                print("No user found");
                              } else if (e.code == "wrong-password") {
                                print("wrong password");
                              }
                            }
                          },
                          child: Text(
                            'Enter',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loggedIn() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "You are now logged in as an administrator.\n\n"
                    "To make any edits to a site, you must navigate to the Location List and click on a card.",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 150,
            ),
          ],
        ),
      ),
    );
  }

  void showLocs() {
    locations.forEach((key, value) {
      print(key);
    });
  }

  void changeToWelcome() {
    setState(() {
      locListUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return administrator ? loggedIn() : welcomeScreen();
  }
}
