import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/location_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:provider/provider.dart';

class MapButtons extends StatelessWidget {
  const MapButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapStateProvider>(builder: (context, mapState, child) {
      return Stack(children: [
        Positioned(
          right: 0,
          top: 100,
          child: FloatingActionButton(
            heroTag: const Text("mapbtn1"),
            onPressed: () {
              mapState.mapMover(
                  mapState.getMapCenter(), mapState.getCurrentZoom() - 1);
            },
            backgroundColor: const Color(0xff3D9198),
            child: const Icon(Icons.zoom_out),
          ),
        ),
        Positioned(
          right: 0,
          top: 170,
          child: FloatingActionButton(
            heroTag: const Text("mapbtn2"),
            onPressed: () {
              mapState.mapMover(
                  mapState.getMapCenter(), mapState.getCurrentZoom() + 1);
            },
            backgroundColor: const Color(0xff3D9198),
            child: const Icon(Icons.zoom_in),
          ),
        ),
        Positioned(
          right: 0,
          top: 260,
          child: Consumer<LocationStateProvider>(
              builder: (context, locationState, child) {
            return FloatingActionButton(
              heroTag: const Text("mapbtn3"),
              onPressed: () {
                mapState.mapMover(locationState.getLatLng(), 15.0);
              },
              backgroundColor: const Color(0xff3D9198),
              child: const Icon(Icons.gps_fixed_outlined),
            );
          }),
        )
      ]);
    });
  }
}
