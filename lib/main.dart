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
                backgroundColor: Colors.red,
                fixedSize: const Size(120, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                side: const BorderSide(color:  Color.fromARGB(255, 136, 138, 135), width: 4),
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                textStyle: const TextStyle(
                  fontSize: 16,
                )),
            // style: ButtonStyle(
            // //   minimumSize: MaterialStateProperty.resolveWith<Size>(
            // // (states) =>
            //   side: MaterialStateProperty.resolveWith<BorderSide>(
            // (states) => BorderSide(color: Color.fromARGB(255, 189, 224, 33), width: 4)),
            //   backgroundColor: MaterialStateProperty.resolveWith<Color>(
            // (states) => Colors.white),
            //   shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
            //     (_) {
            //       return RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
            //     }),
            //   textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            //     (states) => TextStyle(color: Colors.red)),
            // ),
          ),
          child: MaterialApp(
              scaffoldMessengerKey: messengerKey,
              navigatorKey: navigatorKey,
              theme: ThemeData(
                  scaffoldBackgroundColor:
                      const Color.fromARGB(255, 56, 47, 66)),
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
