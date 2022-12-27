import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class PinsProvider with ChangeNotifier {
  late bool isButton = false;

  late String selectedInput = '';

  final TextEditingController startPointController =
      TextEditingController(text: 'Start Point');
  final TextEditingController endPointController =
      TextEditingController(text: 'End Point');

  void setButton(bool value) {
    isButton = value;
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
}
