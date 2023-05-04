// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/clientHome_screen.dart';
import 'package:fitnessco/screens/signUp_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/OvalButton_widget.dart';
import 'package:fitnessco/widgets/FitnesscoTextField_widget.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 100,
                ),
                const SizedBox(height: 100),
                fitnesscoTextField("Enter Email Address", Icons.email_outlined,
                    false, _emailTextController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 50),
                ovalButton(context, "LOG IN", () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    print("SUCCESS LOG IN");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClientHomeScreen()));
                  }).onError((error, stackTrace) {
                    print("MAY MALI KA BOI");
                  });
                }),
                const SizedBox(height: 10),
                _signUpOption(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton _signUpOption(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()));
        },
        child: const Text("Don't have an account? ",
            style: TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
                fontSize: 15)));
  }
}
