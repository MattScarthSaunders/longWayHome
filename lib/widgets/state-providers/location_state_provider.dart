import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationStateProvider with ChangeNotifier {
  double _lat = 0.0;
  double _lng = 0.0;
  Location _location = Location();

  //sets current user location
  locateMe() async {
    _location.onLocationChanged.listen((res) {
      if (res.latitude != _lat || res.longitude != _lng) {
        _lat = res.latitude ?? 00;
        _lng = res.longitude ?? 00;
        notifyListeners();
      }
    });
  }

  getLatLng() {
    return LatLng(_lat, _lng);
  }

  getLngLat() {
    return [_lng, _lat];
  }

  init() {
    _lat = 0.0;
    _lng = 0.0;
    _location = Location();
    notifyListeners();
  }
}
