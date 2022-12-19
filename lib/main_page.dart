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
    final _mapController = MapController();

    return FutureBuilder(
        future: _determinePosition(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            var latitude = snapshot.data?.latitude ?? 00;
            var longitude = snapshot.data?.longitude ?? 00;
            print(latitude);
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: LatLng(53.95968, -1.074224),
                            zoom: 13,
                          ),
                          nonRotatedChildren: [],
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
                            point: LatLng(latitude, longitude),
                            builder: (ctx) => Container(
                              key: Key('blue'),
                              child: Icon(
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
                color: Color(0xff344955),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: 56.0,
                  child: Row(children: <Widget>[
                    BottomDrawerWidget(),
                  ]),
                ),
              ),
            );
          } else {
            return Text('oh shit');
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
