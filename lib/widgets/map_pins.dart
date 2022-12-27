import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class PinsProvider with ChangeNotifier {
  Map mapPins = {
    "start": "",
    "end": "",
    "isButton": false,
    "isEnd": false,
    "isStart": false
  };

  late bool isStart = false;

  late String selectedInput = '';

  final TextEditingController startPointController =
      TextEditingController(text: 'Start Point');
  final TextEditingController endPointController =
      TextEditingController(text: 'End Point');

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

  getPostcode(cords) async {
    try {
//NOTE: IN TESTING THIS IS NOT 100% ACCURATE. Not our code, it's the package. Some postcodes come out incomplete.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(cords.latitude, cords.longitude);

      String postCode = placemarks[0].postalCode ?? "";
      if (selectedInput == 'start') {
        startPointController.text = postCode;
      } else if (selectedInput == 'end') {
        endPointController.text = postCode;
      }
      return postCode;
    } catch (e) {
      return cords;
    }
  }

  getCoords(postcode) async {
    List<Location> locations = await locationFromAddress(postcode);
    return locations[0];
  }
}
