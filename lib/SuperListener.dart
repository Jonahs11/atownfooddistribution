import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/MapPage.dart';
import 'package:atownfooddistribution/InformationPage.dart';

class SuperListener {
  static  MyHomePageState homePage;
  static MapPageState mapPage;
  static WelcomeScreenState welcomeScreen;
  static InformationPageState informationPage;


  static void setPages({
    MyHomePageState hPage,
    MapPageState mPage,
    WelcomeScreenState wScreen,
    InformationPageState iPage,
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
  }

  static void navTo(int index) {
    homePage.screenChanger(index);
  }

  static void loadMap() {
    mapPage.checkFirebase();
    //mapPage.moveToMyLoc();
  }

}