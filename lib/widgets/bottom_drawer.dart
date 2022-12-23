import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomDrawerWidget extends StatefulWidget {
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
                  showMenu();
                })));
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
