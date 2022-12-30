import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
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
    var mapStateSetter = context.read<MapStateProvider>();
    mapStateSetter.setInitialPosition();

    return Scaffold(
      floatingActionButton: const MapButtons(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer2<MapStateProvider, FormStateProvider>(
              builder: (context, mapStateListener, pinStateListener, child) {
            return Flexible(
                child: FlutterMap(
                    mapController: mapStateListener.mapController,
                    options: MapOptions(
                      center: LatLng(0.0, 0.0),
                      zoom: 15,
                      onTap: (tapPosition, point) {
                        setFormMarkers(
                            pinStateListener, mapStateListener, point);
                      },
                    ),
                    nonRotatedChildren: const [],
                    children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  mapStateListener.routePolyLine,
                  const CurrentPOSMarker(),
                  MarkerLayer(markers: [
                    mapStateListener.startMark,
                    mapStateListener.endMark
                  ]),
                  mapStateListener.localPOIMarkers,
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

  setFormMarkers(pinStateListener, mapStateListener, point) {
    var pinStateSetter = context.read<FormStateProvider>();
    var mapStateSetter = context.read<MapStateProvider>();

    if (pinStateListener.selectedInput == "Start") {
      pinStateSetter.setButton(false);
      pinStateSetter.getPostcode(point);
      mapStateSetter.setMarkerLocation(point, "Start");
      mapStateSetter.setCoords(point, "Start");
      if (mapStateListener.endCoord.isNotEmpty) {
        mapStateSetter.setInitialRoute();
      }
    } else if (pinStateListener.selectedInput == "End") {
      pinStateSetter.setButton(false);
      pinStateSetter.getPostcode(point);
      mapStateSetter.setMarkerLocation(point, "End");
      mapStateSetter.setCoords(point, "End");
      if (mapStateListener.startCoord.isNotEmpty) {
        mapStateSetter.setInitialRoute();
      }
    }
  }
}
