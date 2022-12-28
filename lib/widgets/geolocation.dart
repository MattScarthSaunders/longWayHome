import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/location_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CurrentPOSMarker extends StatefulWidget {
  const CurrentPOSMarker({
    super.key,
  });
  @override
  // ignore: library_private_types_in_public_api
  _CurrentPOSMarkerState createState() => _CurrentPOSMarkerState();
}

class _CurrentPOSMarkerState extends State<CurrentPOSMarker> {
  @override
  Widget build(BuildContext context) {
    var locationState = context.read<LocationStateProvider>();

    locationState.locateMe();

    return Consumer<LocationStateProvider>(
        builder: (context, locationStateProvider, child) {
      var mapState = context.read<MapStateProvider>();
      mapState.userCoord = [locationState.lng, locationState.lat];
      return MarkerLayer(markers: [
        Marker(
          width: 80,
          height: 80,
          point: LatLng(locationStateProvider.lat, locationStateProvider.lng),
          builder: (ctx) => Container(
            key: const Key('blue'),
            child: const Icon(
              Icons.gps_fixed_outlined,
              color: Color(0xff31AFB9),
              size: 30.0,
            ),
          ),
        ),
      ]);
    });
  }
}

Future<LocationData> initialPosition(serviceEnabled, permissionGranted) async {
  Location location = Location();
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  }
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }
  return await location.getLocation();
}
