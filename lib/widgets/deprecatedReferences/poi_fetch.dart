// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/widgets/api_utils.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class PoiMarkers extends StatefulWidget {
//   PoiMarkers(
//       {required this.startCoordinate,
//       required this.endCoordinate,
//       this.markerLimit = 10,
//       this.buffer = 120,
//       this.categoryIds = const [620]});

//   List startCoordinate;
//   List endCoordinate;
//   int markerLimit;
//   int buffer;
//   List categoryIds;

//   @override
//   // ignore: library_private_types_in_public_api
//   _PoiMarkerState createState() => _PoiMarkerState();
// }

// class _PoiMarkerState extends State<PoiMarkers> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: fetchInitialRoute(widget.startCoordinate, widget.endCoordinate)
//             .then((response) {
//           var coordinates = json.decode(response.body.toString())["features"][0]
//               ["geometry"]["coordinates"];
//           return fetchRoutePOIData(coordinates, widget.buffer,
//               widget.markerLimit, widget.categoryIds);
//         }).then((res) => res.body),
//         builder: ((context, snapshot) {
//           if (snapshot.hasData) {
//             List<Marker> allMarkers = [];
//             var parsed = json.decode(snapshot.data.toString());
//             int featureTotal = widget.markerLimit > parsed["features"].length
//                 ? parsed["features"].length
//                 : widget.markerLimit;

//             // print(parsed["features"]);
//             for (var i = 0; i < featureTotal; i++) {
//               var lon = parsed["features"][i]["geometry"]["coordinates"][0];
//               var lat = parsed["features"][i]["geometry"]["coordinates"][1];

//               // print(lon);
//               allMarkers.add(Marker(
//                   point: LatLng(lat ?? 00, lon ?? 00),
//                   builder: (context) => FlutterLogo()));
//             }

//             return MarkerLayer(markers: allMarkers);
//           } else {
//             return CircularProgressIndicator();
//           }
//         }));
//   }
// }


//this is deprecated, keep for reference
