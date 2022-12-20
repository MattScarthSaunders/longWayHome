import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return FutureBuilder(
        //can use a list of futures with Future.wait(Future[]) to have map react to multiple futures
        future: _determinePosition(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var currentUserLatitude = snapshot.data?.latitude ?? 00;
            var currentUserLongitude = snapshot.data?.longitude ?? 00;
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            center: LatLng(
                                currentUserLatitude, currentUserLongitude),
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
                        MarkerLayer(markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: LatLng(
                                currentUserLatitude, currentUserLongitude),
                            builder: (ctx) => Container(
                              key: const Key('blue'),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ])
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
            return const Text('oh shit');
          }
        }));
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  return await Geolocator.getCurrentPosition();
}
