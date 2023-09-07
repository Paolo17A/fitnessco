// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
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
    return Container(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (Route<dynamic> route) => false);
            });
          },
          child: const Text("LOG OUT")),
    );
  }
}
