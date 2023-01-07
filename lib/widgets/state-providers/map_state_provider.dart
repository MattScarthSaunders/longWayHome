import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:flutter_application_1/widgets/utils.dart';
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
  List mapRouteToSave = [];

  //rendering
  bool isInitialRouteLoading = false;
  bool isPOILoading = false;
  bool isRouteLoading = false;

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
      setRoutePOI(120, 15, [130], [224, 226, 230, 232, 240]);
      isInitialRouteLoading = false;
      notifyListeners();
    });
  }

  //this handles retrieving the local POIs
  void setRoutePOI(buffer, markerLimit, categoryGroupIds, categoryIds) {
    List tempCoords = [];
    isPOILoading = true;

    plottedRoute.forEach((latlng) {
      tempCoords.add([latlng.longitude, latlng.latitude]);
    });

    //fetch local POI data from api
    fetchRoutePOIData(
            tempCoords, buffer, markerLimit, categoryGroupIds, categoryIds)
        .then((res) {
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

      sortPOIsDistance(allPOIMarkerCoords, [startCoord[1], startCoord[0]]);

      for (var i = 0; i < allPOIMarkerCoords.length; i++) {
        tempMarkers.add(Utils.buildPOIMarker(allPOIMarkerCoords[i]));
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
            borderStrokeWidth: 2,
            borderColor: const Color.fromARGB(255, 12, 53, 129),
            points: routePoints,
            color: const Color.fromARGB(255, 96, 167, 224),
            strokeWidth: 5,
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
  void plotSavedRoute(coords) {
    init();

    allPOIMarkerCoords = coords["POIs"];
    startCoord = coords["start"];
    endCoord = coords["end"];

    setRoute();

    List<Marker> tempMarkers = [];

    print(allPOIMarkerCoords);

    for (var i = 0; i < allPOIMarkerCoords.length; i++) {
      tempMarkers.add(Utils.buildPOIMarker(allPOIMarkerCoords[i]));
    }

    allPOIMarkers = tempMarkers;

    localPOIMarkers = MarkerLayer(markers: allPOIMarkers);
    isPOILoading = false;

    startMark = Marker(
      point: LatLng(startCoord[1], startCoord[0]),
      width: 100,
      height: 100,
      builder: (ctx) => Container(
        key: const Key('start'),
        child: const Icon(
          Icons.location_on,
          color: Colors.green,
          size: 30.0,
        ),
      ),
    );

    endMark = Marker(
      point: LatLng(endCoord[1], endCoord[0]),
      width: 100,
      height: 100,
      builder: (ctx) => Container(
        key: const Key('end'),
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 30.0,
        ),
      ),
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
      body: json.encode({
        'routeName': routeName,
        'routeData': {
          "start": startCoord,
          "end": endCoord,
          "POIs": allPOIMarkerCoords
        }
      }),
    );
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

  void initStartMarker() {
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
    startCoord = [];
    plottedRoute = [];
    allPOIMarkerCoords = [];
    allPOIMarkers = [];
    localPOIMarkers = const MarkerLayer(markers: []);

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

    notifyListeners();
  }

  void initEndMarker() {
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
    endCoord = [];
    plottedRoute = [];
    allPOIMarkerCoords = [];
    allPOIMarkers = [];
    localPOIMarkers = const MarkerLayer(markers: []);

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
    localPOIMarkers = const MarkerLayer(markers: []);
    notifyListeners();
  }
}
