import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/api_utils.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:flutter_application_1/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapStateProvider with ChangeNotifier {
  //input
  List _startCoord = [];
  List _endCoord = [];
  List _userCoord = [];
  final _mapController = MapController();
  final _serviceEnabled = false;
  PermissionStatus? _permissionGranted;

  //coords
  List<LatLng> _plottedRoute = [];
  List _allPOIMarkerCoords = [];
  List<Marker> _allPOIMarkers = [];

  //rendering
  bool _isInitialRouteLoading = false;
  bool _isPOILoading = false;
  bool _isRouteLoading = false;
  bool _isRoutePlotted = false;

  Marker _startMark = Marker(
    point: LatLng(0.0, 0.0),
    builder: (ctx) => Container(),
  );
  Marker _endMark = Marker(
    point: LatLng(0.0, 0.0),
    builder: (ctx) => Container(),
  );
  Widget _routePolyLine = PolylineLayer();
  Widget _localPOIMarkers = const MarkerLayer();

  getStartCoords() {
    return _startCoord;
  }

  setStartCoords(List value) {
    _startCoord = value;
    notifyListeners();
  }

  getEndCoords() {
    return _endCoord;
  }

  setEndCoords(List value) {
    _endCoord = value;
    notifyListeners();
  }

  getPOICoords() {
    return _allPOIMarkerCoords;
  }

  getMapController() {
    return _mapController;
  }

  getMapCenter() {
    return _mapController.center;
  }

  getCurrentZoom() {
    return _mapController.zoom;
  }

  mapMover(LatLng center, double zoom) {
    _mapController.move(center, zoom);
    notifyListeners();
  }

  getPolyLine() {
    return _routePolyLine;
  }

  getStartMarker() {
    return _startMark;
  }

  getEndMarker() {
    return _endMark;
  }

  getLocalPOIs() {
    return _localPOIMarkers;
  }

  getInitialRouteStatus() {
    return _isInitialRouteLoading;
  }

  getRouteStatus() {
    return _isRouteLoading;
  }

  getPOIStatus() {
    return _isPOILoading;
  }

  getIsRoutePlotted() {
    return _isRoutePlotted;
  }

  setIsRoutePlotted(bool value) {
    _isRoutePlotted = value;
    notifyListeners();
  }

  //sets start and end point coords
  void setCoords(point, String type) {
    if (type == 'Start') {
      _startCoord = [point.longitude, point.latitude];
    } else if (type == 'End') {
      _endCoord = [point.longitude, point.latitude];
    }
    notifyListeners();
  }

  //sets initial user position on map
  void setInitialPosition() {
    initialPosition(_serviceEnabled, _permissionGranted).then((res) {
      _userCoord = [res.longitude, res.latitude];
      _mapController.move(LatLng(_userCoord[1], _userCoord[0]), 15);
      notifyListeners();
    });
  }

  //this handles generating an initial route between two points
  void setInitialRoute() {
    List<LatLng> tempRoute = [];
    _isInitialRouteLoading = true;
    //fetch route from api
    fetchInitialRoute(_startCoord, _endCoord).then((res) {
      final parsedRoute = json.decode(res.body.toString())["features"][0]
          ["geometry"]["coordinates"];

      parsedRoute.forEach((point) {
        tempRoute.add(LatLng(point[1], point[0]));
      });

      _plottedRoute = tempRoute;

      _routePolyLine = PolylineLayer(
        polylineCulling: false,
        polylines: [
          Polyline(
            points: _plottedRoute,
            color: Colors.blue,
            strokeWidth: 6,
          ),
        ],
      );
      setRoutePOI(120, 15, [130], [224, 226, 230, 232, 240]);
      _isInitialRouteLoading = false;
      notifyListeners();
    });
  }

  //this handles retrieving the local POIs
  void setRoutePOI(
      int buffer, int markerLimit, List categoryGroupIds, List categoryIds) {
    List tempCoords = [];
    _isPOILoading = true;

    _plottedRoute.forEach((latlng) {
      tempCoords.add([latlng.longitude, latlng.latitude]);
    });

    //fetch local POI data from api
    fetchRoutePOIData(
            tempCoords, buffer, markerLimit, categoryGroupIds, categoryIds)
        .then((res) {
      _allPOIMarkerCoords = [];
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

        _allPOIMarkerCoords.add([
          lat,
          lon,
          parsed["features"][i]["properties"]["osm_tags"] != null
              ? parsed["features"][i]["properties"]["osm_tags"]["name"]
              : "",
        ]);
      }

      sortPOIsDistance(_allPOIMarkerCoords, [_startCoord[1], _startCoord[0]]);

      for (var i = 0; i < _allPOIMarkerCoords.length; i++) {
        tempMarkers.add(Utils.buildPOIMarker(_allPOIMarkerCoords[i]));
      }

      _allPOIMarkers = tempMarkers;
      _localPOIMarkers = MarkerLayer(markers: _allPOIMarkers);
      _isPOILoading = false;

      notifyListeners();
    });
  }

  //this handles generating the final route polyline
  void setRoute() {
    _isRoutePlotted = false;
    List fullRouteCoords = [
      [_startCoord[0], _startCoord[1]]
    ];

    sortPOIsDistance(_allPOIMarkerCoords, [_startCoord[1], _startCoord[0]])
        .forEach((marker) {
      fullRouteCoords.add([marker[1], marker[0]]);
    });

    fullRouteCoords.add([_endCoord[0], _endCoord[1]]);

    _isRouteLoading = true;

    //fetch route polyline from api
    fetchRoute(fullRouteCoords).then((res) {
      final routePolyPoints = decodePolyline(
          json.decode(res.body.toString())["routes"][0]["geometry"]);

      List<LatLng> routePoints = [];

      routePolyPoints.forEach((point) {
        routePoints.add(LatLng(point[0].toDouble(), point[1].toDouble()));
      });

      _routePolyLine = PolylineLayer(
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

      _isRouteLoading = false;
      _isRoutePlotted = true;
      notifyListeners();
    });
  }

//this handles generating the saved route polyline
  void plotSavedRoute(coords) {
    initAll();

    _allPOIMarkerCoords = coords["POIs"];
    _startCoord = coords["start"];
    _endCoord = coords["end"];

    setRoute();

    List<Marker> tempMarkers = [];

    for (var i = 0; i < _allPOIMarkerCoords.length; i++) {
      tempMarkers.add(Utils.buildPOIMarker(_allPOIMarkerCoords[i]));
    }

    _allPOIMarkers = tempMarkers;

    _localPOIMarkers = MarkerLayer(markers: _allPOIMarkers);
    _isPOILoading = false;

    _startMark = Marker(
      point: LatLng(_startCoord[1], _startCoord[0]),
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

    _endMark = Marker(
      point: LatLng(_endCoord[1], _endCoord[0]),
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

  //sets start and end point markers on map
  void setMarkerLocation(point, String type) {
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
      _startMark = mark;
    } else if (type == "End") {
      _endMark = mark;
    }

    notifyListeners();
  }

  List sortPOIsDistance(List poiList, List startPoint) {
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

    return sortByDistance(poiList, startPoint);
  }

  void initMarker(String type) {
    Marker newMark = Marker(
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
    if (type == "Start") {
      _startCoord = [];
      _startMark = newMark;
    } else if (type == "End") {
      _endCoord = [];
      _endMark = newMark;
    }
  }

  void initPoly() {
    _routePolyLine = PolylineLayer(
      polylineCulling: false,
      polylines: [
        Polyline(
          points: [],
          color: Colors.blue,
          strokeWidth: 10,
        ),
      ],
    );
  }

  void initInitial() {
    _plottedRoute = [];
    _allPOIMarkerCoords = [];
    _allPOIMarkers = [];
    _localPOIMarkers = const MarkerLayer(markers: []);
    _isRoutePlotted = false;
  }

  void initInitialise() {
    initInitial();
    initPoly();
    notifyListeners();
  }

  //resets state
  void initAll() {
    _startCoord = [];
    _endCoord = [];
    initMarker("Start");
    initMarker("End");
    initInitialise();
    notifyListeners();
  }
}
