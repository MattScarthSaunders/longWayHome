import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
import 'package:flutter_application_1/widgets/map_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  AddressFormState createState() {
    return AddressFormState();
  }
}

class AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  getPostcode(cords) async {
    try {
      List splitString = cords.split(', ');

      double lat = double.parse(splitString[0]);
      double lng = double.parse(splitString[1]);

//NOTE: IN TESTING THIS IS NOT 100% ACCURATE. Not our code, it's the package.
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      // print(placemarks[0].postalCode);

      String postCode = placemarks[0].postalCode ?? "";

      return postCode;
    } catch (e) {
      return cords;
    }
  }

  getCoords(postcode) async {
    List<Location> locations = await locationFromAddress(postcode);
    return locations[0];
  }

  @override
  void initState() {
    super.initState();
    final pinsProvider = context.read<PinsProvider>();
    // var endPostCode = pinsProvider.mapPins['end'];

    pinsProvider.addListener(() {
      getPostcode(pinsProvider.mapPins['start']).then((postCode) {
        pinsProvider.startPointController.text = postCode;
      });
      getPostcode(pinsProvider.mapPins['end']).then((postCode) {
        pinsProvider.endPointController.text = postCode;
      });
    });
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      final pinsProvider = context.read<PinsProvider>();

      final newWalk = {
        'startPoint': pinsProvider.startPointController.text,
        'endPoint': pinsProvider.endPointController.text,
      };
      var mapState = context.read<MapStateProvider>();
      mapState.setRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(
        r'^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\s?[0-9][A-Za-z]{2})$');
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<PinsProvider>(builder: (context, pinsProvider, child) {
                return TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Start position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: pinsProvider.startPointController,
                  // onChanged: (value) => pinsProvider.addStartPin(value),
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                );
              }),
              ElevatedButton(
                onPressed: () {
                  var mapState = context.read<MapStateProvider>();
                  var pinState = context.read<PinsProvider>();

                  if (regex.hasMatch(pinState.startPointController.text)) {
                    getCoords(pinState.startPointController.text).then((res) {
                      mapState.setStartMarkerLocation(res);
                      mapState.startCoord = [res.longitude, res.latitude];
                      if (mapState.endCoord.isNotEmpty) {
                        mapState.setInitialRoute();
                      }
                    });
                  }
                },
                child: const Text('Set Start'),
              ),
              Consumer<PinsProvider>(
                builder: (context, pinsProvider, child) => TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'End position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: pinsProvider.endPointController,
                  // onChanged: (value) => pinsProvider.addEndPin(value),
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  var mapState = context.read<MapStateProvider>();
                  var pinState = context.read<PinsProvider>();

                  if (regex.hasMatch(pinState.startPointController.text)) {
                    getCoords(pinState.endPointController.text).then((res) {
                      mapState.setEndMarkerLocation(res);
                      mapState.endCoord = [res.longitude, res.latitude];
                      if (mapState.endCoord.isNotEmpty) {
                        mapState.setInitialRoute();
                      }
                    });
                  }
                },
                child: const Text('Set End'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Consumer<PinsProvider>(
                  builder: (context, pinsProvider, child) => Row(
                    children: [
                      ElevatedButton(
                        onPressed: pinsProvider.mapPins["isButton"]
                            ? null
                            : () {
                                pinsProvider.isButton(true);
                                pinsProvider.start(true);
                              },
                        child: const Text('start'),
                      ),
                      ElevatedButton(
                        onPressed: pinsProvider.mapPins["isButton"]
                            ? null
                            : () {
                                pinsProvider.isButton(true);
                                pinsProvider.end(true);
                              },
                        child: const Text('end'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _submitForm();
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
