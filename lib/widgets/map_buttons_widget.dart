import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/location_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapButtons extends StatelessWidget {
  const MapButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapStateProvider>(
        builder: (context, mapStateListener, child) {
      return Stack(children: [
        Positioned(
          right: 0,
          top: 100,
          child: FloatingActionButton(
            heroTag: const Text("mapbtn1"),
            onPressed: () {
              mapStateListener.mapController.move(
                  mapStateListener.mapController.center,
                  mapStateListener.mapController.zoom - 1);
            },
            backgroundColor: const Color(0xff31AFB9),
            child: const Icon(Icons.zoom_out),
          ),
        ),
        Positioned(
          right: 0,
          top: 170,
          child: FloatingActionButton(
            heroTag: const Text("mapbtn2"),
            onPressed: () {
              mapStateListener.mapController.move(
                  mapStateListener.mapController.center,
                  mapStateListener.mapController.zoom + 1);
            },
            backgroundColor: const Color(0xff31AFB9),
            child: const Icon(Icons.zoom_in),
          ),
        ),
        Positioned(
          right: 0,
          top: 260,
          child: Consumer<LocationStateProvider>(
              builder: (context, locationStateListener, child) {
            return FloatingActionButton(
              heroTag: const Text("mapbtn3"),
              onPressed: () {
                mapStateListener.mapController.move(
                    LatLng(
                        locationStateListener.lat, locationStateListener.lng),
                    15);
              },
              backgroundColor: const Color(0xff31AFB9),
              child: const Icon(Icons.gps_fixed_outlined),
            );
          }),
        )
      ]);
    });
  }
}
