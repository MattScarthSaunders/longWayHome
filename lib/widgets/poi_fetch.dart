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

    final area = await http.post(
        Uri.parse(
            'https://api.openrouteservice.org/v2/isochrones/foot-walking'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': apiKey,
        },
        body: jsonEncode({
          "locations": [
            [-1.07412, 53.95978]
          ],
          "range_type": "time",
          "range": [1200],
        }));

    // var data = json.decode(area.body);

    // Map<String, dynamic> map = json.decode(area.body);
    // List<dynamic> data = map["dataKey"];
    // print(data.runtimeType);
    // var data = json.decode(area.body)["features"][0]["geometry"];
    // print(data.runtimeType);
    // debugPrint(data["features"][0]["geometry"]);
    // log(data["features"][0]["geometry"]);

    // print(json.decode(area.body).features[0].geometry);

    // var somevar = json.decode(area.body.toString());

    // print(somevar["features"][0]);
    // print(somevar["features"][0].runtimeType);

    final data =
        Map<String, dynamic>.from(json.decode(area.body)["features"][0]);
    print(data.runtimeType);

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
          //   [8.8034, 53.0756],
          //   [8.7834, 53.0456]
          // ],
          "geojson": {
            "type": "Polygon",
            "coordinates": [
              [
                [8.80864522981668685, 53.07594435294385704],
                [8.80864522981668685, 53.07536364271325624],
                [8.80824790176417238, 53.07508856944613029],
                [8.80803395588974247, 53.07545533380229585],
                [8.80821733806782525, 53.07589850739933013],
                [8.80864522981668685, 53.07594435294385704]
              ]
            ]
          },
          "buffer": 200
        },
        "limit": 50,
        "filters": {
          "category_group_ids": widget.categoryIds,
        }
      }),
    );
    // print(response.body);
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
            int featureTotal = widget.markerLimit > parsed["features"].length
                ? parsed["features"].length
                : widget.markerLimit;

            // print(parsed["features"]);
            for (var i = 0; i < featureTotal; i++) {
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
