import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:provider/provider.dart';

class FormContent extends StatefulWidget {
  const FormContent({super.key, required this.type});

  final String type;
  @override
  // ignore: library_private_types_in_public_api
  _FormContentState createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  final regex = RegExp(
      r'^([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\s?[0-9][A-Za-z]{2})$');

  @override
  Widget build(BuildContext context) {
    return Consumer<FormStateProvider>(
        builder: (context, formStateGetter, child) {
      return Center(
          child: Row(
        children: [
          Visibility(
            visible: !formStateGetter.getStartButtonStatus() &&
                    widget.type == "Start" ||
                !formStateGetter.getEndButtonStatus() && widget.type == "End",
            child: IconButton(
                onPressed: () {
                  MapStateProvider mapState = context.read<MapStateProvider>();
                  mapState.initMarker(widget.type);
                  mapState.initInitialise();
                  if (widget.type == "Start") formStateGetter.initStart();
                  if (widget.type == "End") formStateGetter.initEnd();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                )),
          ),
          Visibility(
            visible: formStateGetter.getStartButtonStatus() &&
                    widget.type == "Start" ||
                formStateGetter.getEndButtonStatus() && widget.type == "End",
            child: IconButton(
                onPressed: () {
                  FormStateProvider formState =
                      context.read<FormStateProvider>();
                  if (formState.getButtonSelected()) {
                    formState.setButtonSelected(false);
                    formState.setInput('none');
                  } else if (!formState.getButtonSelected()) {
                    formState.setButtonSelected(true);
                    formState.setInput(widget.type);
                  }
                },
                iconSize: 30,
                icon: Icon(Icons.location_on,
                    color: widget.type == "Start"
                        ? formStateGetter.getStartIconColor()
                        : formStateGetter.getEndIconColor())),
          ),
          Expanded(
              child: TextFormField(
                  enabled: formStateGetter.getStartButtonStatus() &&
                          widget.type == "Start" ||
                      formStateGetter.getEndButtonStatus() &&
                          widget.type == "End",
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '${widget.type} Postcode',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  controller: widget.type == "Start"
                      ? formStateGetter.getStartPointInput()
                      : formStateGetter.getEndPointInput(),
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
            onPressed: postCodeSetter(formStateGetter, regex, widget.type),
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

  postCodeSetter(FormStateProvider formStateGetter, RegExp regex, String type) {
    if (!formStateGetter.getStartButtonStatus() && type == "Start" ||
        !formStateGetter.getEndButtonStatus() && type == "End") {
      return null;
    } else {
      MapStateProvider mapState = context.read<MapStateProvider>();
      FormStateProvider formState = context.read<FormStateProvider>();

      TextEditingController pointController = type == "Start"
          ? formStateGetter.getStartPointInput()
          : formStateGetter.getEndPointInput();

      if (regex.hasMatch(pointController.text)) {
        formState.getCoords(pointController.text).then((res) {
          mapState.setMarkerLocation(res, type);
          type == "Start"
              ? mapState.setStartCoords([res.longitude, res.latitude])
              : mapState.setEndCoords([res.longitude, res.latitude]);

          if (mapState.getEndCoords().isNotEmpty &&
              mapState.getStartCoords().isNotEmpty) {
            mapState.setInitialRoute();
          }
        });

        formState.setButtonSelected(false);
        formState.setInput('none');
      }
    }
  }
}
