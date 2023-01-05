import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';

class FormStateProvider with ChangeNotifier {
  late bool isButton = false;
  late bool startComplete = false;
  late bool endComplete = false;

  late bool isStartButtonEnabled = true;
  late bool isEndButtonEnabled = true;

  late String selectedInput = '';

  var startIconColor = Color(0xFF66717C);
  var endIconColor = Color(0xFF66717C);

  var isVisible = false;

  TextEditingController startPointController = TextEditingController();
  TextEditingController endPointController = TextEditingController();
  TextEditingController routeNameInputController = TextEditingController();

  // TextEditingController endPointController = TextEditingController(text: '');

//sets when a button has been pressed? idk? It all breaks if I remove this.
  void setButton(bool value) {
    isButton = value;
    notifyListeners();
  }

  //sets current form input type
  setInput(type) {
    selectedInput = type;
    if (type == "Start") {
      startIconColor = Colors.blue;
      endIconColor = Color(0xFF66717C);
    } else if (type == "End") {
      startIconColor = Color(0xFF66717C);
      endIconColor = Colors.blue;
    } else {
      startIconColor = Color(0xFF66717C);
      endIconColor = Color(0xFF66717C);
    }

    notifyListeners();
  }

  //gets postcode from coords
  getPostcode(cords) async {
    try {
//NOTE: IN TESTING THIS IS NOT 100% EFFECTIVE. Some postcodes come out incomplete.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(cords.latitude, cords.longitude);
      String postCode = "";

      for (int i = 0; i < placemarks.length; i++) {
        if ((placemarks[i].postalCode?.length ?? 0) < 4) {
          continue;
        } else {
          postCode = placemarks[i].postalCode ?? "";
          break;
        }
      }

      // postCode = "Could not find Postcode";

      // String postCode = placemarks[0].postalCode ?? "";
      if (selectedInput == 'Start') {
        startPointController.text = postCode;
      } else if (selectedInput == 'End') {
        endPointController.text = postCode;
      }
      // pointController.text = postCode;
      print(placemarks);
      print(postCode);
      return postCode;
    } catch (e) {
      return cords;
    }
  }

  //gets coords from postcode
  getCoords(postcode) async {
    print(postcode);
    List<Location> locations = await locationFromAddress(postcode);
    print(locations);
    return locations[0];
  }

  //notifies when certain form section is filled out
  formSectionComplete(type) {
    if (type == "Start") {
      startComplete = true;
    } else if (type == "End") {
      endComplete = true;
    }
    notifyListeners();
  }

  //resets state
  init() {
    isStartButtonEnabled = true;
    isEndButtonEnabled = true;
    isButton = false;
    startComplete = false;
    endComplete = false;
    selectedInput = '';
    startIconColor = Color(0xFF66717C);
    endIconColor = Color(0xFF66717C);
    startPointController = TextEditingController(text: '');
    endPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initEnd() {
    isEndButtonEnabled = true;
    isButton = false;
    endComplete = false;
    selectedInput = '';
    endIconColor = Color(0xFF66717C);
    endPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initStart() {
    isStartButtonEnabled = true;
    isButton = false;
    startComplete = false;
    selectedInput = '';
    startIconColor = Color(0xFF66717C);
    startPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }
}
