import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';

class PinsProvider with ChangeNotifier {
  Map mapPins = {
    "start": "start location",
    "end": "end location",
    "isButton": false,
    "isEnd": false,
    "isStart": false
  };

  late bool isStart = false;

  void addStartPin(String start) {
    mapPins["start"] = start;
    notifyListeners();
  }

  void addEndPin(String end) {
    mapPins["end"] = end;
    notifyListeners();
  }

  void isButton(bool value) {
    mapPins["isButton"] = value;
    notifyListeners();
  }

  void start(bool value) {
    mapPins["isStart"] = value;
    notifyListeners();
  }

  void end(bool value) {
    mapPins["isEnd"] = value;
    notifyListeners();
  }
}
