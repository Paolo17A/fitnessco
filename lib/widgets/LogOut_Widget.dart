// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

import '../screens/sign_in_screen.dart';

class LogOutWidget extends StatelessWidget {
  const LogOutWidget({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: gradientOvalButton(
          label: "LOG OUT",
          onTap: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (Route<dynamic> route) => false);
            });
          }),
    );
  }
}
