import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class TestRoute extends StatefulWidget {
  TestRoute(
      {required this.positionCoordinate,
      this.markerLimit = 10,
      this.categoryIds = const [620]});

  List positionCoordinate;
  int markerLimit;
  List categoryIds;

  @override
  // ignore: library_private_types_in_public_api
  _TestRouteState createState() => _TestRouteState();
}

class _TestRouteState extends State<TestRoute> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchIsochroneBoundary(widget.positionCoordinate)
            .then((isochroneGeoJson) {
          return fetchIsochronePOIData(
              isochroneGeoJson, widget.markerLimit, widget.categoryIds);
        }).then((response) {
          //initiaise list with start point
          List coords = [];
          coords.add(
              [widget.positionCoordinate[1], widget.positionCoordinate[0]]);

          //decode response
          var parsed = json.decode(response.body.toString());
          int featureTotal = widget.markerLimit > parsed["features"].length
              ? parsed["features"].length
              : widget.markerLimit;

          // adding pois
          for (var i = 0; i < featureTotal; i++) {
            var lon = parsed["features"][i]["geometry"]["coordinates"][0];
            var lat = parsed["features"][i]["geometry"]["coordinates"][1];
            coords.add([lon, lat]);
          }

          //add end point
          coords.add([
            widget.positionCoordinate[1] + 0.005,
            widget.positionCoordinate[0]
          ]);

          print(coords);
          return fetchRoute(coords);
        }).then((response) => response.body),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final routePolyline = decodePolyline(
                json.decode(snapshot.data.toString())["routes"][0]["geometry"]);
            List<LatLng> routePoints = [];
            routePolyline.forEach((point) {
              routePoints.add(LatLng(point[0].toDouble(), point[1].toDouble()));
            });

            return PolylineLayer(
              polylineCulling: false,
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.blue,
                ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        }));
  }
}
