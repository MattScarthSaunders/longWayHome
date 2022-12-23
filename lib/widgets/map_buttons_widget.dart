import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:location/location.dart';

class MapButtons extends StatelessWidget {
  MapButtons(this.mapController, this.lat, this.lng, this.serviceEnabled,
      this.permissionGranted);
  MapController mapController;
  double lat;
  double lng;
  bool serviceEnabled;
  PermissionStatus? permissionGranted;

  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        right: 0,
        top: 100,
        child: FloatingActionButton(
          onPressed: () {
            mapController.move(mapController.center, mapController.zoom - 1);
          },
          backgroundColor: const Color(0xff31AFB9),
          child: const Icon(Icons.zoom_out),
        ),
      ),
      Positioned(
        right: 0,
        top: 170,
        child: FloatingActionButton(
          onPressed: () {
            mapController.move(mapController.center, mapController.zoom + 1);
          },
          backgroundColor: const Color(0xff31AFB9),
          child: const Icon(Icons.zoom_in),
        ),
      ),
      Positioned(
        right: 0,
        top: 260,
        child: FloatingActionButton(
          onPressed: () {
            initialPosition(serviceEnabled, permissionGranted).then((res) {
              lat = res.latitude ?? 00;
              lng = res.longitude ?? 00;
              mapController.move(LatLng(lat, lng), 15);
            });
          },
          backgroundColor: const Color(0xff31AFB9),
          child: const Icon(Icons.navigation),
        ),
      )
    ]);
  }
}
