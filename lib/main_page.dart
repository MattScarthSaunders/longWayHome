import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_drawer.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/map_buttons_widget.dart';
import 'package:flutter_application_1/utils/user_api.dart';
import 'package:flutter_application_1/widgets/state-providers/profile_state_provider.dart';
import 'package:flutter_application_1/utils/utils.dart';
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
    MapStateProvider mapState = context.read<MapStateProvider>();
    ProfileStateProvider profileState = context.read<ProfileStateProvider>();
    mapState.setInitialPosition();

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
              builder: (context, mapStateGetter, formStateGetter, child) {
            return Flexible(
                child: FlutterMap(
                    mapController: mapStateGetter.getMapController(),
                    options: MapOptions(
                      center: LatLng(0.0, 0.0),
                      zoom: 15,
                      onTap: (tapPosition, point) {
                        setFormMarkers(formStateGetter, mapStateGetter, point);
                      },
                    ),
                    nonRotatedChildren: const [],
                    children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  mapStateGetter.getPolyLine(),
                  const CurrentPOSMarker(),
                  MarkerLayer(markers: [
                    mapStateGetter.getStartMarker(),
                    mapStateGetter.getEndMarker()
                  ]),
                  mapStateGetter.getLocalPOIs(),
                  isLoading(mapStateGetter),
                ]));
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
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

  setFormMarkers(formStateGetter, mapStateGetter, point) {
    FormStateProvider formState = context.read<FormStateProvider>();
    MapStateProvider mapState = context.read<MapStateProvider>();
    String type = formStateGetter.getSelectedInput();
    formState.disableInput(type);
    mapState.setMarkerLocation(point, type);
    mapState.setCoords(point, type);

    if (type == "Start" && mapStateGetter.getEndCoords().isNotEmpty) {
      mapState.setInitialRoute();
    } else if (type == "End" && mapStateGetter.getStartCoords().isNotEmpty) {
      mapState.setInitialRoute();
    }
  }

  isLoading(mapState) {
    bool a = mapState.getInitialRouteStatus();
    bool b = mapState.getPOIStatus();
    bool c = mapState.getRouteStatus();
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
