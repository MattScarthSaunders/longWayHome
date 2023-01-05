import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/auth_page.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:flutter_application_1/widgets/state-providers/form_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/location_state_provider.dart';
import 'package:flutter_application_1/widgets/state-providers/map_state_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => FormStateProvider()),
          ChangeNotifierProvider(create: (context) => MapStateProvider()),
          ChangeNotifierProvider(create: (context) => LocationStateProvider()),
        ],
        child: ElevatedButtonTheme(
          data: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3D9198),
                fixedSize: const Size(130, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
                side: const BorderSide(color:  Color.fromARGB(255, 0, 0, 0), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
          ),
          child: MaterialApp(
              scaffoldMessengerKey: messengerKey,
              navigatorKey: navigatorKey,
              theme: ThemeData(
                  scaffoldBackgroundColor:
                      Color(0xff222E34)),
              home: Scaffold(
                  body: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: ((contexts, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (snapshot.hasData) {
                    return const MainPage();
                  } else {
                    return const AuthPage();
                  }
                }),
              ))),
        ));
  }
}
