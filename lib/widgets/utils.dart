import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Utils {
  //controls validation error display above keyboard
  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static buildPOIMarker(poiData) {
    return Marker(
      point: LatLng(poiData[0], poiData[1]),
      width: 100,
      height: 100,
      builder: (ctx) => GestureDetector(
        onTap: () => showDialog<String>(
          context: ctx,
          builder: (BuildContext context) => AlertDialog(
            titlePadding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
            title: Text(
              poiData[2] == "" ? "POI Name not Found" : poiData[2],
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xff222E34),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Close'),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xff3D9198)),
                ),
              ),
            ],
          ),
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30.0,
        ),
      ),
    );
  }
}
