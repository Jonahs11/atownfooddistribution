import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:atownfooddistribution/WelcomeScreen.dart';
import 'package:atownfooddistribution/MapPage.dart';

class SuperListener {
  static  MyHomePageState homePage;
  static MapPageState mapPage;
  static WelcomeScreenState welcomeScreen;


  static void setPages({
    MyHomePageState hPage,
    MapPageState mPage,
    WelcomeScreenState wScreen,
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
  }

  static void navTo(int index) {
    homePage.screenChanger(index);
  }

}