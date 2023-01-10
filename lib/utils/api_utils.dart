import 'dart:convert';
import 'package:flutter_application_1/apikeys.dart';
import 'package:http/http.dart' as http;

fetchInitialRoute(startPoint, endPoint) async {
  return await http.get(Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-hiking?api_key=$openrouteservicekey&start=${startPoint[0]},${startPoint[1]}&end=${endPoint[0]},${endPoint[1]}'));
}

fetchRoutePOIData(List coordinates, int buffer, int markerLimit,
    List categoryGroupIds, List categoryIds) async {
  return await http.post(
    Uri.parse('https://api.openrouteservice.org/pois'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': openrouteservicekey,
    },
    body: jsonEncode({
      "request": "pois",
      "geometry": {
        "geojson": {"type": "LineString", "coordinates": coordinates},
        "buffer": buffer
      },
      "limit": markerLimit,
      "filters": {
        "category_group_ids": categoryGroupIds,
        "category_ids": categoryIds
      },
    }),
  );
}

fetchRoute(List coordinates) async {
  //coordinates structure: [[lng,lat],[lng,lat]...]

  return await http.post(
      Uri.parse('https://api.openrouteservice.org/v2/directions/foot-hiking'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': openrouteservicekey,
      },
      body: jsonEncode({
        "coordinates": coordinates,
        "preference": "fastest",
      }));
}

fetchIsochroneBoundary(positionCoordinate) async {
  return await http.post(
      Uri.parse('https://api.openrouteservice.org/v2/isochrones/foot-hiking'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': openrouteservicekey,
      },
      body: jsonEncode({
        "locations": [
          [positionCoordinate[1], positionCoordinate[0]]
        ],
        "range_type": "time",
        "range": [600],
      }));
}

fetchIsochronePOIData(isochroneGeoJson, markerLimit, categoryIds) async {
  return await http.post(
    Uri.parse('https://api.openrouteservice.org/pois'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': openrouteservicekey,
    },
    body: jsonEncode({
      "request": "pois",
      "geometry": {
        "geojson": {
          "type": "Polygon",
          "coordinates": json.decode(isochroneGeoJson.body)["features"][0]
              ["geometry"]["coordinates"]
        },
        "buffer": 200
      },
      "limit": markerLimit,
      "filters": {
        "category_group_ids": categoryIds,
      }
    }),
  );
}
