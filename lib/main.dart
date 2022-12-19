import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/auth_page.dart';
import 'package:flutter_application_1/main_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(scaffoldBackgroundColor: Color.fromARGB(255, 56, 47, 66)),
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: ((contexts, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            } else if (snapshot.hasError){
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.hasData) {
              return MainPage();
            } else {
              return AuthPage();
            }
          }),
        )
      )
     
    );
  }
}