import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
import 'package:flutter_application_1/widgets/map_state_provider.dart';
import 'package:provider/provider.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  AddressFormState createState() => AddressFormState();
}

class AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  _submitForm() {
    if (_formKey.currentState!.validate()) {
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
                  var pinState = context.read<PinsProvider>();
                  if (pinState.isButton) {
                    return;
                  } else {
                    pinState.setButton(true);
                    pinState.selectedInput = "start";
                  }
                },
                child: const Text('start'),
              ),
              ElevatedButton(
                onPressed: () {
                  var mapState = context.read<MapStateProvider>();
                  var pinState = context.read<PinsProvider>();

                  if (regex.hasMatch(pinState.startPointController.text)) {
                    pinState
                        .getCoords(pinState.startPointController.text)
                        .then((res) {
                      mapState.setMarkerLocation(res, "start");
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
                    pinState
                        .getCoords(pinState.endPointController.text)
                        .then((res) {
                      mapState.setMarkerLocation(res, "end");
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
                        onPressed: pinsProvider.isButton
                            ? null
                            : () {
                                var pinState = context.read<PinsProvider>();
                                pinState.setButton(true);
                                pinState.selectedInput = "start";
                              },
                        child: const Text('start'),
                      ),
                      ElevatedButton(
                        onPressed: pinsProvider.isButton
                            ? null
                            : () {
                                var pinState = context.read<PinsProvider>();
                                pinState.setButton(true);
                                pinState.selectedInput = "end";
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
