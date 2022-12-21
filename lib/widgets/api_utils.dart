import 'dart:convert';
import 'package:http/http.dart' as http;

fetchIsochroneBoundary(positionCoordinate) async {
  const apiKey = '5b3ce3597851110001cf62489513c460675e42199a86c0f6d7133d72';

  return await http.post(
      Uri.parse('https://api.openrouteservice.org/v2/isochrones/foot-walking'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': apiKey,
      },
      body: jsonEncode({
        "locations": [
          [positionCoordinate[1], positionCoordinate[0]]
        ],
        "range_type": "time",
        "range": [600],
      }));
}

fetchPOIData(isochroneGeoJson, markerLimit, categoryIds) async {
  const apiKey = '5b3ce3597851110001cf62489513c460675e42199a86c0f6d7133d72';

  return await http.post(
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
