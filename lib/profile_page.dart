import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/location_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/profile_state_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final profileState1 = context.read<ProfileStateProvider>();
    if (profileState1.getUserDataStatus()) {
      profileState1.getRouteList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xff3D9198),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Saved Routes',
              style: TextStyle(
                  fontSize: 26, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Consumer<ProfileStateProvider>(
                builder: (context, profileState, child) {
                  if (profileState.getListLoadingStatus()) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    List mapPoints = profileState.getMapPoints();
                    if (mapPoints.isNotEmpty) {
                      return ListView.builder(
                        itemCount: mapPoints.length,
                        itemBuilder: (context, index) {
                          final route = mapPoints[index];
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(route["routeName"]),
                                      const Spacer(),
                                      IconButton(
                                          onPressed: () {
                                            _confirmDelete(context, index);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                  subtitle: Text(route["dateCreated"]),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          context
                                              .read<MapStateProvider>()
                                              .plotSavedRoute(
                                                  route["routeData"]);

                                          Navigator.pop(context);
                                        },
                                        child: const Text("See Route on map"))
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text("No saved routes");
                    }
                  }
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Signed In as',
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(height: 8),
            Text(
              user.email!,
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 121, 34, 23)),
                child: const Text(
                  'Sign Out',
                ),
                onPressed: () {
                  context.read<MapStateProvider>().initAll();
                  context.read<FormStateProvider>().init();
                  context.read<ProfileStateProvider>().init();
                  context.read<LocationStateProvider>().init();

                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, index) async {
  return showDialog(
      context: context,
      builder: (context) {
        return Consumer<FormStateProvider>(
            builder: (context, formStateListener, child) {
          return AlertDialog(
            title: const Text('Delete Route from Profile?'),
            actions: <Widget>[
              Row(
                children: [
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
                          backgroundColor: const Color(0xFF31AFB9)),
                      child: const Text('Confirm'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ],
          );
        });
      });
}
