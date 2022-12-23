import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
import 'package:flutter_application_1/widgets/map_state_provider.dart';
import 'package:flutter_application_1/widgets/map_buttons_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/widgets/geolocation.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var mapState = context.read<MapStateProvider>();
    mapState.setInitialPosition();

    return Scaffold(
      floatingActionButton: MapButtons(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer2<MapStateProvider, PinsProvider>(
              builder: (context, mapStateProvider, pinsProvider, child) {
            return Flexible(
                child: FlutterMap(
                    mapController: mapStateProvider.mapController,
                    options: MapOptions(
                      center: LatLng(0.0, 0.0),
                      zoom: 15,
                      onTap: (tapPosition, point) {
                        if (pinsProvider.mapPins["isStart"]) {
                          pinsProvider.handleStartLatLng(point);
                          pinsProvider.isButton(false);
                          mapStateProvider.setStartMarkerLocation(point);
                          mapStateProvider.startCoord = [
                            point.longitude,
                            point.latitude
                          ];
                          if (mapStateProvider.endCoord.isNotEmpty) {
                            mapStateProvider.setInitialRoute();
                          }
                        } else if (pinsProvider.mapPins["isEnd"]) {
                          pinsProvider.handleEndLatLng(point);
                          pinsProvider.isButton(false);
                          mapStateProvider.setEndMarkerLocation(point);
                          mapStateProvider.endCoord = [
                            point.longitude,
                            point.latitude
                          ];
                          if (mapStateProvider.startCoord.isNotEmpty) {
                            mapStateProvider.setInitialRoute();
                          }
                        }
                      },
                    ),
                    nonRotatedChildren: const [],
                    children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  CurrentPOSMarker(),
                  MarkerLayer(markers: [
                    mapStateProvider.startMark,
                    mapStateProvider.endMark
                  ]),
                  mapStateProvider.localPOIMarkers,
                  mapStateProvider.routePolyLine,
                ]));
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: const Color(0xff344955),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(
            children: const [BottomDrawerWidget()],
          ),
        ),
      ),
    );
  }
}
