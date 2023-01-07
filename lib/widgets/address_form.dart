import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/profile_state_provider.dart';
import 'package:flutter_application_1/widgets/user_api.dart';
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
                  setFormContent("Start"),
                  const SizedBox(
                    height: 10,
                  ),
                  setFormContent("End"),
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
                            mapStateSetter.init();
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
                      ElevatedButton(
                          onPressed: () {
                            routeNameInputDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3D9198),
                              fixedSize: const Size(80, 30)),
                          child: const Text("Save")),
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
                controller: formStateListener.routeNameInputController,
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
                      postNewRoute(userID, routeName, mapState.startCoord,
                              mapState.endCoord, mapState.allPOIMarkerCoords)
                          .then((res) {
                        print('posted ${res.body}');
                      });
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

  // saveWalk(routeName) {
  //   var mapStateSetter = context.read<MapStateProvider>();
  //   mapStateSetter.saveRoute(routeName);
  // }

  setFormContent(type) {
    final regex = RegExp(
        r'^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\s?[0-9][A-Za-z]{2})$');

    return Consumer<FormStateProvider>(
        builder: (context, formStateListener, child) {
      return Center(
          child: Row(
        children: [
          Visibility(
            visible: formStateListener.isStartButtonEnabled == false &&
                    type == "Start" ||
                formStateListener.isEndButtonEnabled == false && type == "End",
            child: IconButton(
                onPressed: () {
                  if (type == "Start") {
                    formStateListener.initStart();
                    var mapStateSetter = context.read<MapStateProvider>();
                    mapStateSetter.initStartMarker();
                  }
                  if (type == "End") {
                    formStateListener.initEnd();
                    var mapStateSetter = context.read<MapStateProvider>();
                    mapStateSetter.initEndMarker();
                  }
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                )),
          ),
          Visibility(
            visible: formStateListener.isStartButtonEnabled == true &&
                    type == "Start" ||
                formStateListener.isEndButtonEnabled == true && type == "End",
            child: IconButton(
              onPressed: () {
                var pinStateSetter = context.read<FormStateProvider>();
                if (pinStateSetter.isButtonSelected) {
                  pinStateSetter.setButton(false);
                  pinStateSetter.setInput('none');
                } else if (!pinStateSetter.isButtonSelected) {
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
          ),
          Expanded(
              // flex: 5,
              child: TextFormField(
                  enabled: formStateListener.isStartButtonEnabled == true &&
                          type == "Start" ||
                      formStateListener.isEndButtonEnabled == true &&
                          type == "End",
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '$type Postcode',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  controller: type == "Start"
                      ? formStateListener.startPointController
                      : formStateListener.endPointController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != "" &&
                          value != "Pin Marker" &&
                          !regex.hasMatch(value!)
                      ? 'Please enter a valid postal code'
                      : null)),
          const SizedBox(
            width: 25,
          ),
          ElevatedButton(
            onPressed: formStateListener.isStartButtonEnabled == false &&
                        type == "Start" ||
                    formStateListener.isEndButtonEnabled == false &&
                        type == "End"
                ? null
                : () {
                    var mapStateSetter = context.read<MapStateProvider>();
                    var pinStateSetter = context.read<FormStateProvider>();

                    var pointController = type == "Start"
                        ? formStateListener.startPointController
                        : formStateListener.endPointController;

                    if (regex.hasMatch(pointController.text)) {
                      pinStateSetter
                          .getCoords(pointController.text)
                          .then((res) {
                        mapStateSetter.setMarkerLocation(res, type);
                        type == "Start"
                            ? mapStateSetter.startCoord = [
                                res.longitude,
                                res.latitude
                              ]
                            : mapStateSetter.endCoord = [
                                res.longitude,
                                res.latitude
                              ];

                        if (mapStateSetter.endCoord.isNotEmpty &&
                            mapStateSetter.startCoord.isNotEmpty) {
                          mapStateSetter.setInitialRoute();
                        }
                      });
                      pinStateSetter.setButton(false);
                      pinStateSetter.setInput('none');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3D9198),
              fixedSize: const Size(80, 30),
            ),
            child: Text('Set $type'),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ));
    });
  }
}
