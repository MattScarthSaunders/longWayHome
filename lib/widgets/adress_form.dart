import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

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

  final TextEditingController _startPointController =
      TextEditingController(text: PinsProvider().mapPins["start"]);
  final TextEditingController _endPointController =
      TextEditingController(text: PinsProvider().mapPins["end"]);

  _submitStart() {
    _startPointController.addListener(() {
      var pins = context.read<PinsProvider>();
      pins.addStartPin(_startPointController.text);
    });
  }

  _submitEnd() {
    _endPointController.addListener(() {
      var pins = context.read<PinsProvider>();
      pins.addEndPin(_endPointController.text);
    });
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newWalk = {
        'startPoint': _startPointController.text,
        'endPoint': _endPointController.text,
      };
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
            Focus(
              onFocusChange: (hasFocus) {
                _submitStart();
              },
              child: Consumer<PinsProvider>(
                builder: (context, pinsProvider, child) => TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Start position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: _startPointController,
                  onChanged: (value) => pinsProvider.addStartPin(value),
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Focus(
              onFocusChange: (value) {
                _submitEnd();
              },
              child: Consumer<PinsProvider>(
                builder: (context, pinsProvider, child) => TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'End position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: _endPointController,
                  onChanged: (value) => pinsProvider.addEndPin(value),
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: context.read<PinsProvider>().mapPins["isStart"]
                        ? null
                        : () {
                            var pins = context.read<PinsProvider>();
                            pins.start(true);
                          },
                    child: const Text('start'),
                  ),
                  ElevatedButton(
                    onPressed: context.read<PinsProvider>().mapPins["isEnd"]
                        ? null
                        : () {
                            var pins = context.read<PinsProvider>();
                            pins.end(true);
                          },
                    child: const Text('end'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
