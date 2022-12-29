import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
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
      var mapStateSetter = context.read<MapStateProvider>();
      mapStateSetter.setRoute();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Consumer<FormStateProvider>(
                      builder: (context, pinStateListener, child) {
                    return TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Start position',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      controller: pinStateListener.startPointController,
                      validator: (value) {
                        if (value == null || !regex.hasMatch(value)) {
                          return 'Please enter a valid postal code';
                        }
                        return null;
                      },
                    );
                  }),
                ),
                IconButton(
                  onPressed: () {
                    var pinStateSetter = context.read<FormStateProvider>();
                    if (pinStateSetter.isButton) {
                      pinStateSetter.setButton(false);

                      pinStateSetter.setInput('none');
                    } else {
                      pinStateSetter.setButton(true);
                      pinStateSetter.setInput('start');
                    }
                  },
                  iconSize: 30,
                  icon: Consumer<FormStateProvider>(
                      builder: (context, pinStateListener, child) {
                    return Icon(
                      Icons.location_on,
                      color: pinStateListener.startIconColor,
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    var mapStateSetter = context.read<MapStateProvider>();
                    var pinStateSetter = context.read<FormStateProvider>();

                    if (regex
                        .hasMatch(pinStateSetter.startPointController.text)) {
                      pinStateSetter
                          .getCoords(pinStateSetter.startPointController.text)
                          .then((res) {
                        mapStateSetter.setMarkerLocation(res, "start");
                        mapStateSetter.startCoord = [
                          res.longitude,
                          res.latitude
                        ];
                        if (mapStateSetter.endCoord.isNotEmpty) {
                          mapStateSetter.setInitialRoute();
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF31AFB9)),
                  child: const Text('Set Start'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Consumer<FormStateProvider>(
                    builder: (context, pinStateListener, child) =>
                        TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'End position',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      controller: pinStateListener.endPointController,
                      validator: (value) {
                        if (value == null || !regex.hasMatch(value)) {
                          return 'Please enter a valid postal code';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    var pinStateSetter = context.read<FormStateProvider>();
                    if (pinStateSetter.isButton) {
                      pinStateSetter.setButton(false);

                      pinStateSetter.setInput('none');
                    } else {
                      pinStateSetter.setButton(true);
                      pinStateSetter.setInput('end');
                    }
                  },
                  iconSize: 30,
                  icon: Consumer<FormStateProvider>(
                      builder: (context, pinStateListener, child) {
                    return Icon(
                      Icons.location_on,
                      color: pinStateListener.endIconColor,
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    var mapStateSetter = context.read<MapStateProvider>();
                    var pinStateSetter = context.read<FormStateProvider>();

                    if (regex
                        .hasMatch(pinStateSetter.startPointController.text)) {
                      pinStateSetter
                          .getCoords(pinStateSetter.endPointController.text)
                          .then((res) {
                        mapStateSetter.setMarkerLocation(res, "end");
                        mapStateSetter.endCoord = [res.longitude, res.latitude];
                        if (mapStateSetter.endCoord.isNotEmpty) {
                          mapStateSetter.setInitialRoute();
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF31AFB9)),
                  child: const Text('Set End'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31AFB9)),
            ),
          ],
        ),
      ),
    );
  }
}
