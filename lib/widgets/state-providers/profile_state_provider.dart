import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/user_api.dart';

class ProfileStateProvider with ChangeNotifier {
  late bool isRouteListLoading = false;
  late bool _isUserDataSet = false;

  late List _mapPoints = [];
  late String userID = "";

  setUserID(inputID) {
    userID = inputID;
    notifyListeners();
  }

  getUserID() {
    return userID;
  }

  getMapPoints() {
    return _mapPoints;
  }

  getUserDataStatus() {
    return _isUserDataSet;
  }

  setUserDataStatus(isSet) {
    _isUserDataSet = isSet;
    notifyListeners();
  }

  getRouteList() {
    isRouteListLoading = true;
    if (userID == "") {
      isRouteListLoading = false;
      notifyListeners();
    } else {
      getRoutes(userID).then((res) {
        List routes = json.decode(res.body)["routes"];
        if (routes == []) {
          _mapPoints = [];
        } else {
          _mapPoints = routes;
        }
        isRouteListLoading = false;
        notifyListeners();
      });
    }
  }

  init() {
    isRouteListLoading = false;
    _isUserDataSet = false;
    _mapPoints = [];
    userID = "";
  }
}
