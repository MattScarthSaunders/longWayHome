import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PoiMarkers extends StatefulWidget {
  PoiMarkers(
      {required this.currentPos,
      this.markerLimit = 10,
      this.categoryIds = const [620]});

  List currentPos;
  int markerLimit;
  List categoryIds;

  @override
  // ignore: library_private_types_in_public_api
  _PoiMarkerState createState() => _PoiMarkerState();
}

class _PoiMarkerState extends State<PoiMarkers> {
  fetchPOIData() async {
    const apiKey = '5b3ce3597851110001cf62489513c460675e42199a86c0f6d7133d72';
    // List<Marker> allMarkers = [];

    final response = await http.post(
      Uri.parse('https://api.openrouteservice.org/pois'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': apiKey,
      },
      body: jsonEncode({
        "request": "pois",
        "geometry": {
          // "bbox": [
          //   [-1.07412, 53.95978],
          //   [-1.07512, 53.95968],
          // ],
          "geojson": {
            "type": "Point",
            "coordinates": [widget.currentPos[1], widget.currentPos[0]],
          },
          "buffer": 200
        },
        "limit": 50,
        "filters": {
          "category_group_ids": widget.categoryIds,
        }
      }),
    );
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchPOIData(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<Marker> allMarkers = [];

            var parsed = json.decode(snapshot.data.toString());
            // print(parsed["features"]);
            for (var i = 0; i < widget.markerLimit; i++) {
              var lon = parsed["features"][i]["geometry"]["coordinates"][0];
              var lat = parsed["features"][i]["geometry"]["coordinates"][1];

              // print(lon);
              allMarkers.add(Marker(
                  point: LatLng(lat ?? 00, lon ?? 00),
                  builder: (context) => FlutterLogo()));
            }

            return MarkerLayer(markers: allMarkers);
          } else {
            return CircularProgressIndicator();
          }
        }));
  }
}
