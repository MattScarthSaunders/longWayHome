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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<FormStateProvider>(
                builder: (context, formStateListener, child) {
              return Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: setFormContent(formStateListener)));
            }),
          ],
        ),
      ),
    );
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      var mapStateSetter = context.read<MapStateProvider>();
      mapStateSetter.setRoute();
    }
  }

  setFormContent(formStateListener) {
    final regex = RegExp(
        r'^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\s?[0-9][A-Za-z]{2})$');

    String type = '';
    if (!formStateListener.startComplete) {
      type = "Start";
    } else {
      type = "End";
    }

    if (formStateListener.startComplete && formStateListener.endComplete) {
      //if form complete, submit and generate route
      return [
        ElevatedButton(
          onPressed: () {
            _submitForm();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF31AFB9)),
          child: const Text('Generate Walk'),
        )
      ];
    } else {
      //return programmatic form entry sections, i.e start location then end location then....
      return [
        Expanded(
            child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '$type Postcode',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                controller: formStateListener.pointController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != "" && !regex.hasMatch(value!)
                    ? 'Please enter a valid postal code'
                    : null)),
        IconButton(
          onPressed: () {
            var pinStateSetter = context.read<FormStateProvider>();
            if (pinStateSetter.isButton) {
              pinStateSetter.setButton(false);

              pinStateSetter.setInput('none');
            } else {
              pinStateSetter.setButton(true);
              pinStateSetter.setInput(type);
            }
          },
          iconSize: 30,
          icon: Consumer<FormStateProvider>(
              builder: (context, pinStateListener, child) {
            return Icon(Icons.location_on,
                color: type == "Start"
                    ? pinStateListener.startIconColor
                    : pinStateListener.endIconColor);
          }),
        ),
        ElevatedButton(
          onPressed: () {
            var mapStateSetter = context.read<MapStateProvider>();
            var pinStateSetter = context.read<FormStateProvider>();

            if (regex.hasMatch(formStateListener.pointController.text)) {
              pinStateSetter
                  .getCoords(formStateListener.pointController.text)
                  .then((res) {
                mapStateSetter.setMarkerLocation(res, type);
                type == "Start"
                    ? mapStateSetter.startCoord = [res.longitude, res.latitude]
                    : mapStateSetter.endCoord = [res.longitude, res.latitude];
                pinStateSetter.formSectionComplete(type);
                pinStateSetter.pointController = TextEditingController();
              });
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF31AFB9)),
          child: const Text('Submit'),
        ),
      ];
    }
  }
}
