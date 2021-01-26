import 'package:flutter/material.dart';

class DecorationInfo {
  static InputDecoration kTextFieldDecoration({String hintText}) {
    const rad = 16.0;
    return InputDecoration(
      hintText: hintText == null ? 'Enter a value' : hintText,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(rad)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(rad)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent, width: 2.5),
        borderRadius: BorderRadius.all(Radius.circular(rad)),
      ),
    );
  }
}
