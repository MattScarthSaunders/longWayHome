import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
// import 'package:latlong2/latlong.dart';

class PinsProvider with ChangeNotifier {
  Map mapPins = {
    "start": "",
    "end": "",
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

  handleStartLatLng(location) {
    String latitude = location.latitude.toString();
    String longitude = location.longitude.toString();
    addStartPin('$latitude, $longitude');
    start(false);
  }

  handleEndLatLng(location) {
    String latitude = location.latitude.toString();
    String longitude = location.longitude.toString();
    addEndPin('$latitude, $longitude');
    end(false);
  }
}
