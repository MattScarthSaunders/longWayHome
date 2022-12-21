import 'package:flutter/material.dart';

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

  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newWalk = {
        'startPoint': _startPointController.text,
        'endPoint': _endPointController.text,
      };
    print(newWalk.toString());
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
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Start position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: _startPointController,
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'End position',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: _endPointController,
                  validator: (value) {
                    if (value == null || !regex.hasMatch(value)) {
                      return 'Please enter a valid postal code';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    // () {
                    //   // Validate returns true if the form is valid, or false otherwise.
                    //   if (_formKey.currentState!.validate()) {
                    //     // If the form is valid, display a snackbar. In the real world,
                    //     // you'd often call a server or save the information in a database.
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text('Processing Data')),
                    //     );
                    //   }
                    // },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            )));
  }
}
