import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapStateProvider with ChangeNotifier {
  List startCoord = [53.7955, -1.5367];
  // List endCoord = [53.7855, -1.5267];
  List<LatLng> plottedRoute = [];
  List<Marker> allMarkers = [];

  late Marker startMark = Marker(
    point: LatLng(startCoord[0], startCoord[1]),
    width: 100,
    height: 100,
    builder: (ctx) => Container(
      key: const Key('blue'),
      child: const Icon(
        Icons.location_on,
        color: Colors.blue,
        size: 30.0,
      ),
    ),
  );

  late Marker endMark = Marker(
    point: LatLng(startCoord[0], startCoord[1]),
    width: 100,
    height: 100,
    builder: (ctx) => Container(
      key: const Key('blue'),
      child: const Icon(
        Icons.location_on,
        color: Colors.blue,
        size: 30.0,
      ),
    ),
  );

  Widget routePolyLine = PolylineLayer(
    polylineCulling: false,
    polylines: [
      Polyline(
        points: [],
        color: Colors.blue,
      ),
    ],
  );

  // getPlottedRoute() {
  //   List<Marker> tempMarkers = [];

  //   plottedRoute.forEach((point) {
  //     tempMarkers.add(Marker(
  //         point: point,
  //         width: 100,
  //         height: 100,
  //         builder: (ctx) => Container(
  //               key: const Key('blue'),
  //               child: const Icon(
  //                 Icons.location_on,
  //                 color: Colors.blue,
  //                 size: 30.0,
  //               ),
  //             )));
  //   });
  //   allMarkers = tempMarkers;
  //   notifyListeners();
  // }

  void setInitialRoute(startPoint, endPoint) {
    plottedRoute = [];
    fetchInitialRoute(startPoint, endPoint).then((res) {
      final parsedRoute = json.decode(res.body.toString())["features"][0]
          ["geometry"]["coordinates"];
      parsedRoute.forEach((point) {
        plottedRoute.add(LatLng(point[1], point[0]));
      });

      routePolyLine = PolylineLayer(
        polylineCulling: false,
        polylines: [
          Polyline(
            points: plottedRoute,
            color: Colors.blue,
          ),
        ],
      );
      return 0;
    }).then((res) {
      notifyListeners();
    });
  }

  void setRoutePOI() {
    // fetchRoutePOIData(coordinates, buffer, markerLimit, categoryIds)
  }

  void setRoute() {}

  void setStartMarkerLocation() {
    startMark = Marker(
      point: LatLng(53.7955, -1.5390),
      width: 100,
      height: 100,
      builder: (ctx) => Container(
        key: const Key('blue'),
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30.0,
        ),
      ),
    );

    notifyListeners();
  }

  void setEndMarkerLocation() {
    endMark = Marker(
      point: LatLng(53.7955, -1.5390),
      width: 100,
      height: 100,
      builder: (ctx) => Container(
        key: const Key('blue'),
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30.0,
        ),
      ),
    );

    notifyListeners();
  }
}
