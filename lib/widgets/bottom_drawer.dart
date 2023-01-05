import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/widgets/address_form.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
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
    return Container(
      width: 370,
      margin: EdgeInsets.only(bottom: 7),
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF31AFB9)),
                  onPressed: () {
                    var formState = context.read<FormStateProvider>();
                    if (formState.isVisible) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    } else {
                      showMenu();
                    }
                    formState.isVisible = !formState.isVisible;
                    formState.notifyListeners();
                  },
                  child: Consumer<FormStateProvider>(
                      builder: (context, formStateListener, child) {
                    if (formStateListener.isVisible) {
                      return const Text("Hide Planner");
                    } else {
                      return const Text('Plan Walk');
                    }
                  })),
            )),
        Spacer(flex: 1),
        Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF31AFB9)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
                  },
                  child: const Text('Profile')),
            ))
      ]),
    );
  }

  showMenu() {
    int drawerHeight = 250;
    showBottomSheet(
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
                              child: ListView(children: const [
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
