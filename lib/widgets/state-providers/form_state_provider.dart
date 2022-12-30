import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class FormStateProvider with ChangeNotifier {
  late bool isButton = false;
  late bool startComplete = false;
  late bool endComplete = false;

  late String selectedInput = '';

  var startIconColor = Colors.black;
  var endIconColor = Colors.black;

  TextEditingController pointController = TextEditingController();
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

  //gets postcode from coords
  getPostcode(cords) async {
    try {
//NOTE: IN TESTING THIS IS NOT 100% EFFECTIVE. Some postcodes come out incomplete.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(cords.latitude, cords.longitude);

      String postCode = placemarks[0].postalCode ?? "";
      // if (selectedInput == 'Start') {
      //   pointController.text = postCode;
      // } else if (selectedInput == 'End') {
      //   endPointController.text = postCode;
      // }
      pointController.text = postCode;
      return postCode;
    } catch (e) {
      return cords;
    }
  }

  //gets coords from postcode
  getCoords(postcode) async {
    List<Location> locations = await locationFromAddress(postcode);
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
    isButton = false;
    startComplete = false;
    endComplete = false;
    selectedInput = '';
    startIconColor = Colors.black;
    endIconColor = Colors.black;
    // startPointController = TextEditingController(text: '');
    // endPointController = TextEditingController(text: '');
    pointController = TextEditingController();
    notifyListeners();
  }
}
