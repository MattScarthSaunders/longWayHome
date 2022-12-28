import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/map_state_provider.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class MapButtons extends StatelessWidget {
  MapButtons();

  Widget build(BuildContext context) {
    return Consumer<MapStateProvider>(
        builder: (context, mapStateProvider, child) {
      return Stack(children: [
        Positioned(
          right: 0,
          top: 100,
          child: FloatingActionButton(
            heroTag: Text("mapbtn1"),
            onPressed: () {
              mapStateProvider.mapController.move(
                  mapStateProvider.mapController.center,
                  mapStateProvider.mapController.zoom - 1);
            },
            backgroundColor: const Color(0xff31AFB9),
            child: const Icon(Icons.zoom_out),
          ),
        ),
        Positioned(
          right: 0,
          top: 170,
          child: FloatingActionButton(
            heroTag: Text("mapbtn2"),
            onPressed: () {
              mapStateProvider.mapController.move(
                  mapStateProvider.mapController.center,
                  mapStateProvider.mapController.zoom + 1);
            },
            backgroundColor: const Color(0xff31AFB9),
            child: const Icon(Icons.zoom_in),
          ),
        ),
        Positioned(
          right: 0,
          top: 260,
          child: FloatingActionButton(
            heroTag: Text("mapbtn3"),
            onPressed: () {
              mapStateProvider.mapController.move(
                  LatLng(mapStateProvider.userCoord[1],
                      mapStateProvider.userCoord[0]),
                  15);
            },
            backgroundColor: const Color(0xff31AFB9),
            child: const Icon(Icons.gps_fixed_outlined),
          ),
        )
      ]);
    });
  }
}
