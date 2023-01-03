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
    final user = FirebaseAuth.instance.currentUser!;

    return FutureBuilder(
        future: getUser(user.email).then((res) {
          return res.body;
        }),
        builder: ((context, snapshot) {
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
                      const Text(
                        'Signed In as',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xffCB8D71)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email!,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: const Color(0xFF31AFB9)),
                          icon: const Icon(Icons.arrow_back, size: 32),
                          label: const Text(
                            'back to map',
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: const Color(0xFF31AFB9)),
                          icon: const Icon(Icons.arrow_back, size: 32),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            context.read<MapStateProvider>().init();
                            context.read<FormStateProvider>().init();
                            context.read<FormStateProvider>().init();

                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pop();
                          }),
                    ],
                  ),
                ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }));
  }
}
