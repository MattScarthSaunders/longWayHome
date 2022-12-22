import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/api_utils.dart';
import 'package:latlong2/latlong.dart';

class BottomDrawerWidget extends StatefulWidget {
  BottomDrawerWidget(
      {required this.notifyParent,
      required this.plottedRoute,
      required this.snapshot});

  List plottedRoute;
  dynamic snapshot;
  final Function() notifyParent;

  @override
  _BottomDrawerWidget createState() => _BottomDrawerWidget();
}

class _BottomDrawerWidget extends State<BottomDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                // style: ElevatedButton.styleFrom(
                //     minimumSize: const Size.fromHeight(50),
                //     backgroundColor: const Color(0xFF31AFB9)),
                child: const Text('New Walk'),
                onPressed: () {
                  doTest(widget.plottedRoute, widget.snapshot);
                  widget.notifyParent();
                })));
  }

  doTest(plottedRoute, snapshot) async {
    // print(plottedRoute.runtimeType);
    List<LatLng> arr = [];
    print("button pressed");
    await fetchInitialRoute(
        [snapshot.data?.latitude ?? 00, snapshot.data?.longitude ?? 00],
        [53.7955, -1.5367]).then((response) {
      final parsedRoute = json.decode(response.body.toString())["features"][0]
          ["geometry"]["coordinates"];
      parsedRoute.forEach((point) {
        plottedRoute.add(LatLng(point[1], point[0]));
      });
      // print("arrr");
      // print(arr);
      // setState(() {
      //   print("insetstate");
      //   plottedRoute = arr;
      // });
      // print("indotest");
      // print(plottedRoute);
    });
    // print(arr);
  }

  showMenu() {
    int drawerHeight = 60;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(16.0),
              //   topRight: Radius.circular(16.0),
              // ),
              color: Color(0xff232f34),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 36,
                ),
                SizedBox(
                    height: (drawerHeight).toDouble(),
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        // Positioned(
                        //   top: -36,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(50)),
                        //         border: Border.all(
                        //             color: Color(0xff232f34), width: 10)),
                        //   ),
                        // ),
                        Positioned(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  "Inbox",
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.inbox,
                                  color: Colors.white,
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                Container(
                  height: 56,
                  color: Color(0xff4a6572),
                )
              ],
            ),
          );
        });
  }
}
