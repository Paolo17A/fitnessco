// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/signin_screen.dart';
import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.purple,
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "YOU ARE IN THE CLIENT HOME PANEL",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                    });
                  },
                  child: const Text("LOG OUT")),
            )
          ],
        ),
      ),
    );
  }
}
