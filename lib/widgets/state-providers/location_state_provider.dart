import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationStateProvider with ChangeNotifier {
  double lat = 0.0;
  double lng = 0.0;
  bool hasChanged = false;
  Location location = Location();
  // PermissionStatus? _permissionGranted;
  locateMe() async {
    //if permision issues arise then add requestservice and requestpermission conditionals here
    // Track user Movements
    location.onLocationChanged.listen((res) {
      if (res.latitude != lat || res.longitude != lng) {
        lat = res.latitude ?? 00;
        lng = res.longitude ?? 00;
        notifyListeners();
      }
    });
  }
}
