import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class PinsProvider with ChangeNotifier {
  late bool isButton = false;

  late String selectedInput = '';

  var startIconColor = Colors.black;
  var endIconColor = Colors.black;

  TextEditingController startPointController = TextEditingController(text: '');
  TextEditingController endPointController = TextEditingController(text: '');

  void setButton(bool value) {
    isButton = value;
    notifyListeners();
  }

  setInput(type) {
    selectedInput = type;
    if (type == "start") {
      startIconColor = Colors.blue;
      endIconColor = Colors.black;
    } else if (type == "end") {
      startIconColor = Colors.black;
      endIconColor = Colors.blue;
    } else {
      startIconColor = Colors.black;
      endIconColor = Colors.black;
    }

    notifyListeners();
  }

  getPostcode(cords) async {
    try {
//NOTE: IN TESTING THIS IS NOT 100% EFFECTIVE. Some postcodes come out incomplete.
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

  init() {
    isButton = false;
    selectedInput = '';
    startIconColor = Colors.black;
    endIconColor = Colors.black;
    startPointController = TextEditingController(text: '');
    endPointController = TextEditingController(text: '');
    notifyListeners();
  }
}
