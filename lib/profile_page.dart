import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:flutter_application_1/widgets/user_api.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var mapStateSetter = context.read<MapStateProvider>();

    mapStateSetter.isRouteListLoading = true;
    mapStateSetter.getRoutes().then((results) {
      mapStateSetter.mapPoints = results["routes"];

      mapStateSetter.isRouteListLoading = false;
    });

    final user = FirebaseAuth.instance.currentUser!;

    _renderSavedRoute(routeCoords) {
      var mapStateSetter = context.read<MapStateProvider>();

      mapStateSetter.plotSavedRoute(routeCoords);
    }

    return FutureBuilder(
        future: getUser(user.email).then((res) {
          return res.body;
        }),
        builder: ((context, snapshot) {
          // print(snapshot.data);
          if (snapshot.hasData) {
            //refer to data as below to render profile information
            return Scaffold(
              appBar: AppBar(
                title: const Text('Home'),
                backgroundColor: const Color(0xff31AFB9),
              ),
              body: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 121, 34, 23)),
                        child: const Text(
                          'Sign Out',
                        ),
                        onPressed: () {
                          context.read<MapStateProvider>().init();
                          context.read<FormStateProvider>().init();
                          context.read<FormStateProvider>().init();

                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop();
                        }),
                        SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      child: Consumer<MapStateProvider>(
                        builder: (context, mapStateProvider, child) {
                          if (mapStateSetter.isRouteListLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                              itemCount: mapStateSetter.mapPoints.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(mapStateSetter
                                            .mapPoints[index]["routeName"]),
                                        subtitle: Text(mapStateSetter
                                            .mapPoints[index]["dateCreated"]),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                _renderSavedRoute(mapStateSetter
                                                        .mapPoints[index]
                                                    ["routeData"]);
                                                Navigator.pop(context);
                                              },
                                              child: Text("See Route on map"))
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Signed In as',
                      style: TextStyle(fontSize: 16, color: Color(0xffCB8D71)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email!,
                      style: const TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(150, 40),
                            backgroundColor: const Color(0xFF31AFB9)),
                        icon: const Icon(Icons.arrow_back, size: 32),
                        label: const Text(
                          'Back to map',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }));
  }
}
