import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/widgets/user_api.dart';
import 'package:flutter_application_1/widgets/utils.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  //controls the login input fields
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 35,
                ),
                Image.asset(
                  'assets/transparent_app_logo.png',
                  scale: 1.5,
                ),
                const Text(
                  'Long Way Home',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontFamily: 'Moon_Dance'),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: emailController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white)),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Enter a valid email'
                          : null,
                ),
                TextFormField(
                  controller: passwordController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white)),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xff3D9198)),
                    icon: const Icon(Icons.lock_open, size: 32),
                    label: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: signUp),
                Container(
                  padding: const EdgeInsets.only(top: 35),
                  child: RichText(
                    text: TextSpan(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        text: 'Already have an account?  ',
                        children: [
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = widget.onClickedSignIn,
                              text: 'Log in',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color:
                                      Theme.of(context).colorScheme.secondary))
                        ]),
                  ),
                )
              ],
            )),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    //sets a loading wheel
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    //firebase sign up
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      final newUser = FirebaseAuth.instance.currentUser!;
      postUser(newUser.email).then((res) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      });
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    //hide loading dialog after logging in
    //Navigator.of(context) not working!
  }
}
