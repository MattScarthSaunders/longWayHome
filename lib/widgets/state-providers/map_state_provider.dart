import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapStateProvider with ChangeNotifier {
  //input
  List startCoord = [];
  List endCoord = [];
  List userCoord = [];
  final mapController = MapController();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;

  //coords
  List<LatLng> plottedRoute = [];
  List allPOIMarkerCoords = [];
  List<Marker> allPOIMarkers = [];

  //rendering
  late Marker startMark = Marker(
    point: LatLng(0.0, 0.0),
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
    point: LatLng(0.0, 0.0),
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
        strokeWidth: 10,
      ),
    ],
  );
  Widget localPOIMarkers = const MarkerLayer(markers: []);

  //sets start and end point coords
  void setCoords(point, type) {
    if (type == 'Start') {
      startCoord = [point.longitude, point.latitude];
    } else if (type == 'End') {
      endCoord = [point.longitude, point.latitude];
    }
  }

  //sets initial user position on map
  void setInitialPosition() {
    initialPosition(serviceEnabled, permissionGranted).then((res) {
      userCoord = [res.longitude, res.latitude];
      return;
    }).then((res) {
      mapController.move(LatLng(userCoord[1], userCoord[0]), 15);
      notifyListeners();
    });
  }

  //this handles generating an initial route between two points
  void setInitialRoute() {
    List<LatLng> tempRoute = [];
    //fetch route from api
    fetchInitialRoute(startCoord, endCoord).then((res) {
      final parsedRoute = json.decode(res.body.toString())["features"][0]
          ["geometry"]["coordinates"];

      parsedRoute.forEach((point) {
        tempRoute.add(LatLng(point[1], point[0]));
      });

      plottedRoute = tempRoute;

      return;
    }).then((res) {
      routePolyLine = PolylineLayer(
        polylineCulling: false,
        polylines: [
          Polyline(
            points: plottedRoute,
            color: Colors.blue,
            strokeWidth: 6,
          ),
        ],
      );
      setRoutePOI(100, 10, [130, 220, 330, 620]);
      notifyListeners();
    });
  }

  //this handles retrieving the local POIs
  void setRoutePOI(buffer, markerLimit, categoryIds) {
    List tempCoords = [];

    plottedRoute.forEach((latlng) {
      tempCoords.add([latlng.longitude, latlng.latitude]);
    });

    //fetch local POI data from api
    fetchRoutePOIData(tempCoords, buffer, markerLimit, categoryIds).then((res) {
      allPOIMarkerCoords = [];
      List<Marker> tempMarkers = [];

      var parsed = json.decode(res.body.toString());
      int featureTotal = 0;
      parsed["features"] == null
          ? featureTotal = 0
          : markerLimit > parsed["features"].length
              ? featureTotal = parsed["features"].length
              : featureTotal = markerLimit;

      for (var i = 0; i < featureTotal; i++) {
        var lon = parsed["features"][i]["geometry"]["coordinates"][0];
        var lat = parsed["features"][i]["geometry"]["coordinates"][1];

        allPOIMarkerCoords.add([lat, lon]);
      }

      allPOIMarkerCoords.forEach((element) {
        tempMarkers.add(Marker(
          point: LatLng(element[0], element[1]),
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
        ));
      });

      allPOIMarkers = tempMarkers;

      return;
    }).then((res) {
      localPOIMarkers = MarkerLayer(markers: allPOIMarkers);
      notifyListeners();
    });
  }

  //this handles generating the final route polyline
  void setRoute() {
    List fullRouteCoords = [
      [startCoord[0], startCoord[1]]
    ];

    allPOIMarkerCoords.forEach((marker) {
      fullRouteCoords.add([marker[1], marker[0]]);
    });

    fullRouteCoords.add([endCoord[0], endCoord[1]]);

    //fetch route polyline from api
    fetchRoute(fullRouteCoords).then((res) {
      final routePolyPoints = decodePolyline(
          json.decode(res.body.toString())["routes"][0]["geometry"]);

      List<LatLng> routePoints = [];

      routePolyPoints.forEach((point) {
        routePoints.add(LatLng(point[0].toDouble(), point[1].toDouble()));
      });

      routePolyLine = PolylineLayer(
        polylineCulling: false,
        polylines: [
          Polyline(
            points: routePoints,
            color: Colors.orange,
            strokeWidth: 6,
          ),
        ],
      );

      return;
    }).then((res) {
      notifyListeners();
    });
  }

//this handles generating the saved route polyline
  void plotSavedRoute(List<dynamic> coords) {
      List<LatLng> latLngList = [];

     for (var dynamicObject in coords) {
    latLngList.add(LatLng(dynamicObject['coordinates'][1], dynamicObject['coordinates'][0]));
  }
    plottedRoute = latLngList;
    routePolyLine = PolylineLayer(
      polylineCulling: false,
      polylines: [
        Polyline(
          points: plottedRoute,
          color: Colors.orange,
          strokeWidth: 6,
        ),
      ],
    );
    notifyListeners();
  }

  void saveRoute(routeName) async {
    await http.post(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/63a08560482372cd329d6888/route"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'routeName': routeName, 'routeData': plottedRoute}),
    );
  }

  Future<Map> getRoutes() async {
    final response = await http.get(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/63a08560482372cd329d6888/routes"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return jsonDecode(response.body);
  }

  //sets start and end point markers on map
  void setMarkerLocation(point, type) {
    final markColor = type == "Start" ? Colors.green : Colors.red;

    Marker mark = Marker(
      point: LatLng(point.latitude, point.longitude),
      width: 100,
      height: 100,
      builder: (ctx) => Container(
        key: const Key('blue'),
        child: Icon(
          Icons.location_on,
          color: markColor,
          size: 30.0,
        ),
      ),
    );

    if (type == 'Start') {
      startMark = mark;
    } else if (type == "End") {
      endMark = mark;
    }

    notifyListeners();
  }

  //resets state
  void init() {
    //input
    startCoord = [];
    endCoord = [];

    //coords
    plottedRoute = [];
    allPOIMarkerCoords = [];
    allPOIMarkers = [];

    startMark = Marker(
      point: LatLng(0.0, 0.0),
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
    endMark = Marker(
      point: LatLng(0.0, 0.0),
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
    routePolyLine = PolylineLayer(
      polylineCulling: false,
      polylines: [
        Polyline(
          points: [],
          color: Colors.blue,
          strokeWidth: 10,
        ),
      ],
    );
    localPOIMarkers = MarkerLayer(markers: []);
    notifyListeners();
  }
}
