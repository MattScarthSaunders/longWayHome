import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class Utils {
  //controls validation error display above keyboard
  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}