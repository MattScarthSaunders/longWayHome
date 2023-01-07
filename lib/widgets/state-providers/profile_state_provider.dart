import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/user_api.dart';

class ProfileStateProvider with ChangeNotifier {
  bool isRouteListLoading = false;
  List _mapPoints = [];

  // setRouteListLoader(isLoading) {
  //   isRouteListLoading = isLoading;
  //   notifyListeners();
  // }

  // setMapPoints(newMapPoints) {
  //   mapPoints = newMapPoints;
  //   notifyListeners();
  // }

  getMapPoints() {
    return _mapPoints;
  }

  getRouteList() {
    isRouteListLoading = true;

    getRoutes().then((results) {
      _mapPoints = results["routes"];
      isRouteListLoading = false;
      return;
    }).then((res) {
      notifyListeners();
    });
  }
}
