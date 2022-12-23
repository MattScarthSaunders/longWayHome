import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
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
  _handleStartLatLng(location) {
    print('this is the start ${location}');
   String latitude = location.latitude.toString();
    String longitude = location.longitude.toString();
    context.read<PinsProvider>().addStartPin('$latitude, $longitude');
    context.read<PinsProvider>().start(false);
  }

  _handleEndLatLng(location) {
    print('this is the end ${location}');
    String latitude = location.latitude.toString();
    String longitude = location.longitude.toString();
    context.read<PinsProvider>().addEndPin('$latitude, $longitude');
    context.read<PinsProvider>().end(false);
    
  }

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
                            onTap: (tapPosition, point) {
                              var pins = context.read<PinsProvider>();

                              if (pins.mapPins["isStart"]) {
                                LatLng location = point;
                                _handleStartLatLng(location);
                                pins.isButton(false);
                              } else if (pins.mapPins["isEnd"]){
                                LatLng location = point;
                                _handleEndLatLng(location);
                                pins.isButton(false);
                              }
                            },
                          ),
                          nonRotatedChildren: const [],
                          children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        CurrentPOSMarker(
                          serviceEnabled: serviceEnabled,
                          permissionGranted: permissionGranted,
                        ),
                      ])),
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                elevation: 0,
                color: const Color(0xff344955),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  height: 56.0,
                  child: Row(children: <Widget>[
                    //pass data into and out of this drawer widget to manipulate map
                    BottomDrawerWidget(),
                  ]),
                ),
              ),
            );
          } else {
            return const Text('Error loading geolocations');
          }
        }));
  }
}
