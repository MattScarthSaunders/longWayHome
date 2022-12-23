import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
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

  final TextEditingController _startPointController =
      TextEditingController(text: 'Start Point');
  final TextEditingController _endPointController =
      TextEditingController(text: 'End Point');

  getPostcode(cords) async {
    try {
      List splitString = cords.split(',');

      double lat = double.parse(splitString[0]);
      double lng = double.parse(splitString[1]);

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      // print(placemarks[0].postalCode);

      String postCode = placemarks[0].postalCode ?? "";

      return postCode;
    } catch (e) {
      return cords;
    }
  }

  @override
  void initState() {
    super.initState();
    final pinsProvider = context.read<PinsProvider>();
    // var endPostCode = pinsProvider.mapPins['end'];

    pinsProvider.addListener(() {
      getPostcode(pinsProvider.mapPins['start']).then((postCode) {
        _startPointController.text = postCode;
      });
      getPostcode(pinsProvider.mapPins['end']).then((postCode) {
        _endPointController.text = postCode;
      });
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
          child: Consumer<PinsProvider>(
            builder: (context, pinsProvider, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<PinsProvider>(
                  builder: (context, pinsProvider, child) => Focus(
                    // onFocusChange: (hasFocus) {
                    //   pinsProvider.addStartPin(_startPointController.text);
                    // },
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Start position',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      controller: _startPointController,
                      // onChanged: (value) => pinsProvider.addStartPin(value),
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
                    pinsProvider.addEndPin(_startPointController.text);
                  },
                  child: Consumer<PinsProvider>(
                    builder: (context, pinsProvider, child) => TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'End position',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      controller: _endPointController,
                      // onChanged: (value) => pinsProvider.addEndPin(value),
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
          ),
        ));
  }
}
