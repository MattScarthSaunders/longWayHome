import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/user_api.dart';

class ProfileStateProvider with ChangeNotifier {
  late bool _isRouteListLoading = false;
  late bool _isUserDataSet = false;

  late List _mapPoints = [];
  late String _userID = "";

  getUserID() {
    return _userID;
  }

  getMapPoints() {
    return _mapPoints;
  }

  getUserDataStatus() {
    return _isUserDataSet;
  }

  getListLoadingStatus() {
    return _isRouteListLoading;
  }

  getRouteList() {
    _isRouteListLoading = true;
    if (_userID == "") {
      _isRouteListLoading = false;
      notifyListeners();
    } else {
      getRoutes(_userID).then((res) {
        List routes = json.decode(res.body)["routes"];
        if (routes == []) {
          _mapPoints = [];
        } else {
          _mapPoints = routes;
        }
        _isRouteListLoading = false;
        notifyListeners();
      });
    }
  }

  setUserDataStatus(isSet) {
    _isUserDataSet = isSet;
    notifyListeners();
  }

  setUserID(inputID) {
    _userID = inputID;
    notifyListeners();
  }

  init() {
    _isRouteListLoading = false;
    _isUserDataSet = false;
    _mapPoints = [];
    _userID = "";
  }
}
