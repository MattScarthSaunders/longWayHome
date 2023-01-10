import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/form_content_widget.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/profile_state_provider.dart';
import 'package:flutter_application_1/utils/user_api.dart';
import 'package:flutter_application_1/utils/utils.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Place a pin or enter a postcode:",
                      style: TextStyle(color: Colors.white)),
                  const FormContent(type: "Start"),
                  const SizedBox(
                    height: 10,
                  ),
                  const FormContent(type: "End"),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(
                        flex: 1,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff3D9198),
                            fixedSize: const Size(80, 30),
                          ),
                          onPressed: () {
                            var mapStateSetter =
                                context.read<MapStateProvider>();
                            var pinStateSetter =
                                context.read<FormStateProvider>();
                            mapStateSetter.initAll();
                            pinStateSetter.init();
                          },
                          child: const Text('Clear')),
                      const Spacer(
                        flex: 1,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff3D9198)),
                        child: const Text('Plot Route'),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Consumer<MapStateProvider>(
                          builder: (context, mapState, child) {
                        return ElevatedButton(
                            onPressed: !mapState.getIsRoutePlotted()
                                ? null
                                : () {
                                    routeNameInputDialog(context);
                                  },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff3D9198),
                                fixedSize: const Size(80, 30)),
                            child: const Text("Save"));
                      }),
                      const Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                ])));
  }

  routeNameInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Consumer<FormStateProvider>(
              builder: (context, formStateListener, child) {
            return AlertDialog(
              title: const Text('Route Name'),
              content: TextField(
                onChanged: (value) {},
                controller: formStateListener.getRouteInputController(),
                decoration: const InputDecoration(hintText: "Name your route"),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7213D)),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3D9198)),
                    child: const Text('Save'),
                    onPressed: () {
                      var routeName =
                          context.read<FormStateProvider>().getRouteName();
                      String userID =
                          context.read<ProfileStateProvider>().getUserID();
                      var mapState = context.read<MapStateProvider>();
                      postNewRoute(userID, routeName, mapState.getStartCoords(),
                          mapState.getEndCoords(), mapState.getPOICoords());
                      context.read<MapStateProvider>().setIsRoutePlotted(false);
                      Utils.confirmationSnackbar(
                          "Route: '$routeName' saved to profile.");
                      Navigator.pop(context);
                    }),
              ],
            );
          });
        });
  }

  submitForm() {
    if (_formKey.currentState!.validate()) {
      var mapStateSetter = context.read<MapStateProvider>();
      mapStateSetter.setRoute();
    }
  }
}
