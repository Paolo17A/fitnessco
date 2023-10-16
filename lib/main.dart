import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessco/screens/admin_home_screen.dart';
import 'package:fitnessco/screens/client_home_screen.dart';
import 'package:fitnessco/screens/complete_profile_screen.dart';
import 'package:fitnessco/screens/forgot_password_screen.dart';
import 'package:fitnessco/screens/profile_completed_screen.dart';
import 'package:fitnessco/screens/trainer_home_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';

import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/welcome_screen.dart';

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

  final Map<String, WidgetBuilder> _routes = {
    '/': (context) => const WelcomeScreen(),
    '/signIn': (context) => const SignInScreen(),
    '/signUp': (context) => const SignUpScreen(),
    '/forgotPassword': (context) => const ForgotPasswordScreen(),
    '/completeProfile': (context) => CompleteProfileScreen(),
    '/profileCompleted': (context) => ProfileCompletedScreen(),
    '/clientHome': (context) => ClientHomeScreen(),
    '/trainerHome': (context) => TrainerHomeScreen(),
    '/adminHome': (context) => AdminHomeScreen()
  };

  final ThemeData _themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: CustomColors.nightSnow),
      scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 245),
      snackBarTheme:
          const SnackBarThemeData(backgroundColor: CustomColors.purpleSnail),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: CustomColors.purpleSnail,
          selectedItemColor: CustomColors.nightSnow),
      dialogBackgroundColor: CustomColors.plasmaTrail,
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black)),
      listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadiusDirectional.all(Radius.circular(10))),
              backgroundColor: CustomColors.purpleSnail)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: CustomColors.purpleSnail,
              textStyle:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20))));

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitnessco',
      theme: _themeData,
      routes: _routes,
      initialRoute: '/',
    );
  }
}
