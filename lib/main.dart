import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessco/screens/signin_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitnessco',
      theme: ThemeData(
          primarySwatch: Colors.purple, cardColor: Colors.purpleAccent),
      home: const SignInScreen(),
    );
  }
}
