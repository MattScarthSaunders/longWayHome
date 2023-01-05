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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Place a pin or enter a postcode:",
                      style: TextStyle(color: Colors.white)),
                  setFormContent("Start"),
                  SizedBox(
                    height: 10,
                  ),
                  setFormContent("End"),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(
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
                      Spacer(
                        flex: 1,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _submitForm();
                          var pinStateSetter =
                              context.read<FormStateProvider>();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff3D9198)),
                        child: const Text('Plot Route'),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _routeNameInputDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff3D9198),
                              fixedSize: const Size(80, 30)),
                          child: Text("Save")),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                ])));
  }

  Future<void> _routeNameInputDialog(BuildContext context) async {
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
                      backgroundColor: Color(0xFFC7213D)),
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
                      _saveWalk(
                          formStateListener.routeNameInputController.text);
                      Navigator.pop(context);
                    }),
              ],
            );
          });
        });
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      var mapStateSetter = context.read<MapStateProvider>();
      mapStateSetter.setRoute();
    }
  }

  _saveWalk(routeName) {
    var mapStateSetter = context.read<MapStateProvider>();
    mapStateSetter.saveRoute(routeName);
  }

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
                icon: Icon(
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
                if (pinStateSetter.isButton) {
                  pinStateSetter.setButton(false);
                  pinStateSetter.setInput('none');
                } else if (!pinStateSetter.isButton) {
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
                    labelStyle: TextStyle(color: Colors.white),
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
          SizedBox(
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
                        pinStateSetter.formSectionComplete(type);

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
              backgroundColor: Color(0xff3D9198),
              fixedSize: const Size(80, 30),
            ),
            child: Text('Set $type'),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ));
    });
  }
}
