import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/widgets/address_form.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
              child: SizedBox(
            height: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3D9198)),
                onPressed: () {
                  handlePlanner();
                },
                child: Consumer<FormStateProvider>(
                    builder: (context, formStateListener, child) {
                  bool isVisible = formStateListener.getVisibility();

                  return Text(isVisible ? "Hide Planner" : "Plan Walk");
                })),
          )),
          Align(
              child: SizedBox(
            height: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3D9198)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfilePage()));
                },
                child: const Text('Profile')),
          )),
        ]);
  }

  handlePlanner() {
    FormStateProvider formState = context.read<FormStateProvider>();
    if (formState.getVisibility()) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      showMenu();
    }
    formState.setVisibility(!formState.getVisibility());
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
              ));
        });
  }
}
