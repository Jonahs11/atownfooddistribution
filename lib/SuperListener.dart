import 'package:distfoodapp/Search.dart';
import 'package:flutter/material.dart';
import 'package:distfoodapp/main.dart';
import 'package:distfoodapp/LoginScreen.dart';
import 'package:distfoodapp/MapPage.dart';
import 'package:distfoodapp/LocationList.dart';
import 'package:latlong/latlong.dart';
import 'package:distfoodapp/CalendarPage.dart';

class SuperListener {
  static MyHomePageState homePage;
  static MapPageState mapPage;
  static WelcomeScreenState welcomeScreen;
  static LocationListState locationlist;
  static CalendarPageState calendarPage;

  Search search = new Search();

  static void setPages(
      {MyHomePageState hPage,
        MapPageState mPage,
        WelcomeScreenState wScreen,
        LocationListState lPage,
        CalendarPageState cPage}) {
    if (hPage != null) {
      homePage = hPage;
    }
    if (mPage != null) {
      mapPage = mPage;
    }
    if (wScreen != null) {
      welcomeScreen = wScreen;
    }
    if (lPage != null) {
      locationlist = lPage;
    }
    if (cPage != null) {
      calendarPage = cPage;
    }
  }

  static void navTo(int index) {
    homePage.screenChanger(index);
  }

  static void loadMap() {
    mapPage.checkFirebase();
    //mapPage.moveToMyLoc();
  }

  static void removeListLocScreen() {
    welcomeScreen.changeToWelcome();
  }

  static void updateFirebase(String notes, String id) {
    mapPage.updateFirebase(notes, id);
  }

  static void updateLocList() {
    locationlist.loadPlacesByDistance();
  }

  static Future<void> updateLocations() async {
    mapPage.checkFirebase();
  }

  static double calcDistance(
      double lat1, double long1, double lat2, double long2) {
    double dist = Distance()
        .calculator
        .distance(LatLng(lat1, long1), LatLng(lat2, long2));
    return dist;
  }

  List getListLocations() {
    return locationlist.getListLocs();
  }

  static Future makeAlert(BuildContext context, String key, Map value,
      bool editable, bool mapPage) {
    return locationlist.createAlertDialog(
        context,
        key,
        value["address"],
        value["notes"],
        value["link"],
        value["schedule"],
        value["requirements"],
        value["phone"],
        value["writtenSched"],
        value["type"],
        editable,
        mapPage);
  }

  static getFavs() {
    return locationlist.favorites;
  }

  static void makeAdmin() {
    locationlist.makeAdmin();
    navTo(2);
  }

  static writeToFile(List favs) {
    locationlist.writeToFile(favs);
  }

  static moveToFavs() {
    locationlist.moveToFavs();
  }

  static makePhoneCall(String url) {
    locationlist.makePhoneCall(url);
  }

  static void loadFirstMonth() {
    calendarPage.loadingFirstMonth();
  }
}
