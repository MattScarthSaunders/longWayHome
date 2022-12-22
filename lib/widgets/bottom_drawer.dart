import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/adress_form.dart';
import 'package:flutter_application_1/widgets/map_pins.dart';
import 'package:provider/provider.dart';

class BottomDrawerWidget extends StatefulWidget {
  const BottomDrawerWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomDrawerWidget createState() => _BottomDrawerWidget();
}

class _BottomDrawerWidget extends State<BottomDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(50),
              //     backgroundColor: const Color(0xFF31AFB9)),
              onPressed: showMenu,
              // style: ElevatedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(50),
              //     backgroundColor: const Color(0xFF31AFB9)),
              child: const Text('New Walk'))),
      Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(50),
              //     backgroundColor: const Color(0xFF31AFB9)),
              onPressed: showMenu,
              // style: ElevatedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(50),
              //     backgroundColor: const Color(0xFF31AFB9)),
              child: const Text('Profile')))
    ]);
  }

  showMenu() {
    int drawerHeight = 250;
    showBottomSheet(
        // isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          final MediaQueryData mediaQueryData = MediaQuery.of(context);

          return Padding(
              padding:
                  EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
              child: SingleChildScrollView(
                  child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff232f34),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                        height: (drawerHeight).toDouble(),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: ListView(children: [
                                AddressForm(),
                              ]),
                            )
                          ],
                        )),
                  ],
                ),
              )));
        });
  }
}
