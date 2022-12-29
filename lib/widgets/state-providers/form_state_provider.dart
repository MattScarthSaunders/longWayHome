import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class FormStateProvider with ChangeNotifier {
  late bool isButton = false;
  late bool startComplete = false;
  late bool endComplete = false;

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
    if (type == "Start") {
      startIconColor = Colors.blue;
      endIconColor = Colors.black;
    } else if (type == "End") {
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
      if (selectedInput == 'Start') {
        startPointController.text = postCode;
      } else if (selectedInput == 'End') {
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

  formSectionComplete(type) {
    if (type == "Start") {
      startComplete = true;
    } else if (type == "End") {
      endComplete = true;
    }
    notifyListeners();
  }

  init() {
    isButton = false;
    startComplete = false;
    endComplete = false;
    selectedInput = '';
    startIconColor = Colors.black;
    endIconColor = Colors.black;
    startPointController = TextEditingController(text: '');
    endPointController = TextEditingController(text: '');
    notifyListeners();
  }
}
