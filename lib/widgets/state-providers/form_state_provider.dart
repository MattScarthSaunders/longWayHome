import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class FormStateProvider with ChangeNotifier {
  late bool isButtonSelected = false;
  late bool isStartButtonEnabled = true;
  late bool isEndButtonEnabled = true;

  late String selectedInput = '';

  var startIconColor = const Color(0xFF66717C);
  var endIconColor = const Color(0xFF66717C);

  var isVisible = false;

  TextEditingController startPointController = TextEditingController();
  TextEditingController endPointController = TextEditingController();
  TextEditingController routeNameInputController = TextEditingController();

//sets when a button has been pressed? idk? It all breaks if I remove this.
  void setButton(bool value) {
    isButtonSelected = value;
    notifyListeners();
  }

  getRouteName() {
    return routeNameInputController.text;
  }

  //sets current form input type
  setInput(type) {
    selectedInput = type;
    if (type == "Start") {
      startIconColor = Colors.blue;
      endIconColor = const Color(0xFF66717C);
    } else if (type == "End") {
      startIconColor = const Color(0xFF66717C);
      endIconColor = Colors.blue;
    } else {
      startIconColor = const Color(0xFF66717C);
      endIconColor = const Color(0xFF66717C);
    }

    notifyListeners();
  }

  //gets coords from postcode
  getCoords(postcode) async {
    List<Location> locations = await locationFromAddress(postcode);
    return locations[0];
  }

  //resets state
  init() {
    isStartButtonEnabled = true;
    isEndButtonEnabled = true;
    isButtonSelected = false;
    selectedInput = '';
    startIconColor = const Color(0xFF66717C);
    endIconColor = const Color(0xFF66717C);
    startPointController = TextEditingController(text: '');
    endPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initEnd() {
    isEndButtonEnabled = true;
    isButtonSelected = false;
    selectedInput = '';
    endIconColor = const Color(0xFF66717C);
    endPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initStart() {
    isStartButtonEnabled = true;
    isButtonSelected = false;
    selectedInput = '';
    startIconColor = const Color(0xFF66717C);
    startPointController = TextEditingController(text: '');
    routeNameInputController = TextEditingController();
    notifyListeners();
  }
}
