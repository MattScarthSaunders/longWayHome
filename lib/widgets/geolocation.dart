import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class CurrentPOSMarker extends StatefulWidget {
  CurrentPOSMarker({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CurrentPOSMarkerState createState() => _CurrentPOSMarkerState();
}

class _CurrentPOSMarkerState extends State<CurrentPOSMarker> {
  double lat = 0.0;
  double lng = 0.0;
  bool hasChanged = false;
  Location location = Location();
  // PermissionStatus? _permissionGranted;
  _locateMe() async {
    //if permision issues arise then add requestservice and requestpermission conditionals here

    // Track user Movements
    location.onLocationChanged.listen((res) {
      if (res.latitude != lat || res.longitude != lng) {
        setState(() {
          lat = res.latitude ?? 00;
          lng = res.longitude ?? 00;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _locateMe();
    return MarkerLayer(markers: [
      Marker(
        width: 80,
        height: 80,
        point: LatLng(lat, lng),
        builder: (ctx) => Container(
          key: const Key('blue'),
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 30.0,
          ),
        ),
      ),
    ]);
  }
}

Future<LocationData> initialPosition(serviceEnabled, permissionGranted) async {
  Location location = Location();
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  }
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }
  return await location.getLocation();
}
