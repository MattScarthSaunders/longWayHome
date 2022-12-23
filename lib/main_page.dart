import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/map_state_provider.dart';
import 'package:flutter_application_1/widgets/deprecatedReferences/poi_fetch.dart';
import 'package:flutter_application_1/widgets/deprecatedReferences/test_route.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<LatLng> plottedRoute = [];

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();
    bool serviceEnabled = false;
    PermissionStatus? permissionGranted;

    return FutureBuilder(
        //can use a list of futures with Future.wait(Future[]) to have map react to multiple futures
        future: initialPosition(serviceEnabled, permissionGranted),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            center: LatLng(snapshot.data?.latitude ?? 00,
                                snapshot.data?.longitude ?? 00),
                            zoom: 15,
                          ),
                          nonRotatedChildren: const [],
                          children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        CurrentPOSMarker(),
                        Consumer<MapStateProvider>(
                            builder: (context, mapStateProvider, child) {
                          return mapStateProvider.localPOIMarkers;
                        }),
                        Consumer<MapStateProvider>(
                            builder: (context, mapStateProvider, child) {
                          return mapStateProvider.routePolyLine;
                        }),
                      ])),
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                elevation: 0,
                color: const Color(0xff344955),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  height: 56.0,
                  child: Row(
                    children: <Widget>[
                      //pass data into and out of this drawer widget to manipulate map
                      BottomDrawerWidget(),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Text('Error loading geolocations');
          }
        }));
  }
}
