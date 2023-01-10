import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class FormStateProvider with ChangeNotifier {
  late bool _isButtonSelected = false;
  late bool _isStartButtonEnabled = true;
  late bool _isEndButtonEnabled = true;

  late String _selectedInput = '';

  Color _startIconColor = const Color(0xFF66717C);
  Color _endIconColor = const Color(0xFF66717C);

  bool _isVisible = false;

  TextEditingController _startPointController = TextEditingController();
  TextEditingController _endPointController = TextEditingController();
  TextEditingController _routeNameInputController = TextEditingController();

//sets when a button has been pressed? idk? It all breaks if I remove this.
  void setButtonSelected(bool value) {
    _isButtonSelected = value;
    notifyListeners();
  }

  getButtonSelected() {
    return _isButtonSelected;
  }

  getStartButtonStatus() {
    return _isStartButtonEnabled;
  }

  getEndButtonStatus() {
    return _isEndButtonEnabled;
  }

  getRouteInputController() {
    return _routeNameInputController;
  }

  getRouteName() {
    return _routeNameInputController.text;
  }

  getStartPointInput() {
    return _startPointController;
  }

  getEndPointInput() {
    return _endPointController;
  }

  getVisibility() {
    return _isVisible;
  }

  getStartIconColor() {
    return _startIconColor;
  }

  getEndIconColor() {
    return _endIconColor;
  }

  getSelectedInput() {
    return _selectedInput;
  }

  //gets coords from postcode
  getCoords(String postcode) async {
    List<Location> locations = await locationFromAddress(postcode);
    return locations[0];
  }

  setVisibility(bool visibility) {
    _isVisible = visibility;
    notifyListeners();
  }

  //sets current form input type
  setInput(String type) {
    _selectedInput = type;
    if (type == "Start") {
      _startIconColor = Colors.blue;
      _endIconColor = const Color(0xFF66717C);
    } else if (type == "End") {
      _startIconColor = const Color(0xFF66717C);
      _endIconColor = Colors.blue;
    } else {
      _startIconColor = const Color(0xFF66717C);
      _endIconColor = const Color(0xFF66717C);
    }

    notifyListeners();
  }

  disableInput(String type) {
    _isButtonSelected = false;
    _selectedInput = "none";

    if (type == "Start") {
      _isStartButtonEnabled = false;
      _startPointController.text = "Pin Marker";
    } else if (type == "End") {
      _isEndButtonEnabled = false;
      _endPointController.text = "Pin Marker";
    }
    notifyListeners();
  }

  //resets state
  init() {
    _isStartButtonEnabled = true;
    _isEndButtonEnabled = true;
    _isButtonSelected = false;
    _selectedInput = '';
    _startIconColor = const Color(0xFF66717C);
    _endIconColor = const Color(0xFF66717C);
    _startPointController = TextEditingController(text: '');
    _endPointController = TextEditingController(text: '');
    _routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initEnd() {
    _isEndButtonEnabled = true;
    _isButtonSelected = false;
    _selectedInput = '';
    _endIconColor = const Color(0xFF66717C);
    _endPointController = TextEditingController(text: '');
    _routeNameInputController = TextEditingController();
    notifyListeners();
  }

  initStart() {
    _isStartButtonEnabled = true;
    _isButtonSelected = false;
    _selectedInput = '';
    _startIconColor = const Color(0xFF66717C);
    _startPointController = TextEditingController(text: '');
    _routeNameInputController = TextEditingController();
    notifyListeners();
  }
}
