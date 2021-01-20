import 'package:atownfooddistribution/Search.dart';
import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:atownfooddistribution/InformationPage.dart';
import 'package:atownfooddistribution/LocationList.dart';
import 'package:latlong/latlong.dart';


class SuperListener {
  static  MyHomePageState homePage;
  static MapPageState mapPage;
  static WelcomeScreenState welcomeScreen;
  static InformationPageState informationPage;
  static LocationListState locationlist;

  Search search = new Search();

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

  // void setMyLocs(Map<String, List> myLocations) {
  //  this.myLocations = myLocations;
  // }


  static void removeListLocScreen() {
    welcomeScreen.changeToWelcome();
  }

  static void updateFirebase(String foodlevel, String notes, String id) {
    mapPage.updateFirebase(foodlevel, notes, id);
  }

  static void updateLocList() {
    locationlist.loadPlacesByDistance();
  }

  static Future<void> updateLocations() async {
     mapPage.checkFirebase();
  }
  // static Future createAlert(BuildContext context, String name, String address, String amountFood, String notes, String link) {
  //   return mapPage.createAlertDialog(context, name, address, amountFood, notes, link);
  // }

  static Future createAlertWEdit(BuildContext context, String name, String address, String amountFood, String notes, String link) {
    return locationlist.createAlertDialog(context, name, address, amountFood, notes, link);
  }

  static double calcDistance(double lat1, double long1, double lat2, double long2) {
    double dist = Distance().calculator.distance(LatLng(lat1, long1), LatLng(lat2, long2));
    return dist;
  }

   List getListLocations() {
    return locationlist.getListLocs();
  }

  static Future makeAlert(BuildContext context, String key, List value) {
    return locationlist.createAlertDialog(context, key, value[0], value[3], value[4], value[5]);
  }

  static getFavs() {
    return locationlist.favorites;
  }

  static writeToFile(List favs) {
    locationlist.writeToFile(favs);
  }

  static moveToFavs() {
    locationlist.moveToFavs();
  }

}