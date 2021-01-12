import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:atownfooddistribution/InformationPage.dart';
import 'package:atownfooddistribution/LocationList.dart';

class SuperListener {
  static  MyHomePageState homePage;
  static MapPageState mapPage;
  static WelcomeScreenState welcomeScreen;
  static InformationPageState informationPage;
  static LocationListState locationlist;

  Map myLocations;

  static void setPages({
    MyHomePageState hPage,
    MapPageState mPage,
    WelcomeScreenState wScreen,
    InformationPageState iPage,
    LocationListState lPage,
}) {
    if(hPage != null) {
      homePage = hPage;
    }
    if(mPage != null) {
      mapPage = mPage;
    }
    if(wScreen != null) {
      welcomeScreen = wScreen;
    }
    if(iPage != null) {
      informationPage = iPage;
    }
    if(lPage != null) {
      locationlist = lPage;
    }
  }

  static void navTo(int index) {
    homePage.screenChanger(index);
  }

  static void loadMap() {
    mapPage.checkFirebase();
    //mapPage.moveToMyLoc();
  }

  void setMyLocs(Map<String, List> myLocations) {
   this.myLocations = myLocations;
  }

  Map getLocs() {
    return myLocations;
  }

  static void removeListLocScreen() {
    welcomeScreen.changeToWelcome();
  }

  static void updateFirebase(String foodlevel, String notes, String id) {
    mapPage.updateFirebase(foodlevel, notes, id);
  }

}