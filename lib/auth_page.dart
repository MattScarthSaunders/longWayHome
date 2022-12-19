import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/login_widget.dart';
import 'package:flutter_application_1/widgets/signup_widget.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool hasAccount = true;
  @override
  Widget build(BuildContext context) => hasAccount
      ? LoginWidget(onClickedSignUp: toggle)
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => hasAccount = !hasAccount);
}
