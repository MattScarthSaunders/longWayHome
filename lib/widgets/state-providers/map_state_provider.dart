import 'dart:convert';
import 'dart:math';
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
  List mapPoints = [];
  List mapRouteToSave = [];

  //rendering
  bool isInitialRouteLoading = false;
  bool isPOILoading = false;
  bool isRouteLoading = false;
  bool isRouteListLoading = false;

  List<bool> showMarkerDialogue = [];
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
    isInitialRouteLoading = true;
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
      isInitialRouteLoading = false;
      notifyListeners();
    });
  }

  //this handles retrieving the local POIs
  void setRoutePOI(buffer, markerLimit, categoryIds) {
    List tempCoords = [];
    isPOILoading = true;

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

        allPOIMarkerCoords.add([
          lat,
          lon,
          parsed["features"][i]["properties"]["osm_tags"] != null
              ? parsed["features"][i]["properties"]["osm_tags"]["name"]
              : "",
        ]);
      }
      for (var i = 0; i < allPOIMarkerCoords.length; i++) {
        tempMarkers.add(Marker(
          point: LatLng(allPOIMarkerCoords[i][0], allPOIMarkerCoords[i][1]),
          width: 100,
          height: 100,
          builder: (ctx) => GestureDetector(
            onTap: () => showDialog<String>(
              context: ctx,
              builder: (BuildContext context) => AlertDialog(
                titlePadding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 0),
                title: Text(
                  allPOIMarkerCoords[i][2] == ""
                      ? "POI Name not Found"
                      : allPOIMarkerCoords[i][2],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xff504958),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Close'),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Color(0xff31AFB9)),
                    ),
                  ),
                ],
              ),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 30.0,
            ),
          ),
        ));
      }

      allPOIMarkers = tempMarkers;
      return;
    }).then((res) {
      localPOIMarkers = MarkerLayer(markers: allPOIMarkers);
      isPOILoading = false;

      notifyListeners();
    });
  }

  //this handles generating the final route polyline
  void setRoute() {
    List fullRouteCoords = [
      [startCoord[0], startCoord[1]]
    ];

    sortPOIsDistance(allPOIMarkerCoords, [startCoord[1], startCoord[0]])
        .forEach((marker) {
      fullRouteCoords.add([marker[1], marker[0]]);
    });

    fullRouteCoords.add([endCoord[0], endCoord[1]]);

    isRouteLoading = true;

    //fetch route polyline from api
    fetchRoute(fullRouteCoords).then((res) {
      final routePolyPoints = decodePolyline(
          json.decode(res.body.toString())["routes"][0]["geometry"]);

      List<LatLng> routePoints = [];

      routePolyPoints.forEach((point) {
        routePoints.add(LatLng(point[0].toDouble(), point[1].toDouble()));
      });

      mapRouteToSave = routePoints;

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
      isRouteLoading = false;

      notifyListeners();
    });
  }

//this handles generating the saved route polyline
  void plotSavedRoute(List<dynamic> coords) {
    init();
    List<LatLng> latLngList = [];

    for (var dynamicObject in coords) {
      latLngList.add(LatLng(
          dynamicObject['coordinates'][1], dynamicObject['coordinates'][0]));
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
      body: json.encode({'routeName': routeName, 'routeData': mapRouteToSave}),
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
    notifyListeners();
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

  List sortPOIsDistance(POIList, startPoint) {
    int distance(coor1, coor2) {
      dynamic x = coor2[0] - coor1[0];
      dynamic y = coor2[1] - coor1[1];
      return (sqrt((x * x) + (y * y)) * 10000).toInt();
    }

    List sortByDistance(coordinates, point) {
      coordinates
          .sort((a, b) => distance(a, point).compareTo(distance(b, point)));
      return coordinates;
    }

    return sortByDistance(POIList, startPoint);
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
