import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:provider/provider.dart';

class FormContent extends StatefulWidget {
  const FormContent({super.key, required this.type});

  final type;
  @override
  // ignore: library_private_types_in_public_api
  _FormContentState createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  @override
  Widget build(BuildContext context) {
    final regex = RegExp(
        r'^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\s?[0-9][A-Za-z]{2})$');

    return Consumer<FormStateProvider>(builder: (context, formState, child) {
      return Center(
          child: Row(
        children: [
          Visibility(
            visible:
                !formState.getStartButtonStatus() && widget.type == "Start" ||
                    !formState.getEndButtonStatus() && widget.type == "End",
            child: IconButton(
                onPressed: () {
                  var mapState = context.read<MapStateProvider>();
                  mapState.initMarker(widget.type);
                  mapState.initInitialise();
                  if (widget.type == "Start") formState.initStart();
                  if (widget.type == "End") formState.initEnd();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                )),
          ),
          Visibility(
            visible:
                formState.getStartButtonStatus() && widget.type == "Start" ||
                    formState.getEndButtonStatus() && widget.type == "End",
            child: IconButton(
              onPressed: () {
                var pinStateSetter = context.read<FormStateProvider>();
                if (pinStateSetter.getButtonSelected()) {
                  pinStateSetter.setButtonSelected(false);
                  pinStateSetter.setInput('none');
                } else if (!pinStateSetter.getButtonSelected()) {
                  pinStateSetter.setButtonSelected(true);
                  pinStateSetter.setInput(widget.type);
                }
              },
              iconSize: 30,
              icon: Consumer<FormStateProvider>(
                  builder: (context, pinStateListener, child) {
                return Icon(Icons.location_on,
                    color: widget.type == "Start"
                        ? pinStateListener.getStartIconColor()
                        : pinStateListener.getEndIconColor());
              }),
            ),
          ),
          Expanded(
              // flex: 5,
              child: TextFormField(
                  enabled: formState.getStartButtonStatus() &&
                          widget.type == "Start" ||
                      formState.getEndButtonStatus() && widget.type == "End",
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '${widget.type} Postcode',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  controller: widget.type == "Start"
                      ? formState.getStartPointInput()
                      : formState.getEndPointInput(),
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
            onPressed: !formState.getStartButtonStatus() &&
                        widget.type == "Start" ||
                    !formState.getEndButtonStatus() && widget.type == "End"
                ? null
                : () {
                    var mapState = context.read<MapStateProvider>();
                    var pinState = context.read<FormStateProvider>();

                    var pointController = widget.type == "Start"
                        ? formState.getStartPointInput()
                        : formState.getEndPointInput();

                    if (regex.hasMatch(pointController.text)) {
                      pinState.getCoords(pointController.text).then((res) {
                        mapState.setMarkerLocation(res, widget.type);
                        widget.type == "Start"
                            ? mapState
                                .setStartCoords([res.longitude, res.latitude])
                            : mapState
                                .setEndCoords([res.longitude, res.latitude]);
                        if (mapState.getEndCoords().isNotEmpty &&
                            mapState.getStartCoords().isNotEmpty) {
                          mapState.setInitialRoute();
                        }
                      });
                      pinState.setButtonSelected(false);
                      pinState.setInput('none');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3D9198),
              fixedSize: const Size(80, 30),
            ),
            child: Text('Set ${widget.type}'),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ));
    });
  }
}
