// ignore_for_file: file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/clientHome_screen.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../widgets/OvalButton_widget.dart';
import '../widgets/FitnesscoTextField_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: [
                fitnesscoTextField("Enter Username", Icons.person_outline,
                    false, _usernameTextController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Email Address", Icons.email, false,
                    _emailTextController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 40),
                fitnesscoTextField("Confirm Password", Icons.lock_outline, true,
                    _confirmPasswordTextController),
                const SizedBox(height: 40),
                ovalButton(context, "REGISTER", () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    print("Success");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClientHomeScreen()));
                  }).onError((error, stackTrace) {
                    print("Error${error.toString()}");
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
