import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessco/screens/signin_screen.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

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
