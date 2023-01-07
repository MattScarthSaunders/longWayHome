import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/map_buttons_widget.dart';
import 'package:flutter_application_1/widgets/user_api.dart';

import 'package:flutter_application_1/widgets/state-providers/profile_state_provider.dart';
import 'package:flutter_application_1/widgets/utils.dart';
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
    var profileState = context.read<ProfileStateProvider>();
    mapStateSetter.setInitialPosition();

    if (!profileState.getUserDataStatus()) {
      final user = FirebaseAuth.instance.currentUser!;
      getUser(user.email).then((res) {
        var userData = json.decode(res.body);
        profileState.setUserID(userData["user"]["_id"]);
        profileState.setUserDataStatus(true);
      }).catchError((e) {
        Utils.showSnackBar("Could not retrieve user data");
        FirebaseAuth.instance.signOut();
      });
    }

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
                  isLoading(mapStateListener),
                ]));
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
              color: Color(0xff222E34),
              border:
                  Border(top: BorderSide(color: Color(0xff255777), width: 3))),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 65.0,
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
      pinStateSetter.setInput("none");
      // pinStateSetter.getPostcode(point);
      mapStateSetter.setMarkerLocation(point, "Start");

      pinStateSetter.isStartButtonEnabled = false;
      pinStateSetter.startPointController.text = "Pin Marker";

      mapStateSetter.setCoords(point, "Start");
      if (mapStateListener.endCoord.isNotEmpty) {
        mapStateSetter.setInitialRoute();
      }
    } else if (pinStateListener.selectedInput == "End") {
      pinStateSetter.setButton(false);
      pinStateSetter.setInput("none");
      // pinStateSetter.getPostcode(point);
      mapStateSetter.setMarkerLocation(point, "End");

      pinStateSetter.isEndButtonEnabled = false;
      pinStateSetter.endPointController.text = "Pin Marker";

      mapStateSetter.setCoords(point, "End");
      if (mapStateListener.startCoord.isNotEmpty) {
        mapStateSetter.setInitialRoute();
      }
    }
  }

  isLoading(mapStateListener) {
    bool a = mapStateListener.isInitialRouteLoading;
    bool b = mapStateListener.isPOILoading;
    bool c = mapStateListener.isRouteLoading;
    if (a || b || c) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Text("fetching map data")
          ],
        ),
      );
    } else {
      return const Center();
    }
  }
}
