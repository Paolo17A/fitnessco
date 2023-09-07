// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/adminHome_screen.dart';
import 'package:fitnessco/screens/clientHome_screen.dart';
import 'package:fitnessco/screens/forgot_password_screen.dart';
import 'package:fitnessco/screens/sign_up_screen.dart';
import 'package:fitnessco/screens/trainer_home_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/OvalButton_widget.dart';
import 'package:fitnessco/widgets/FitnesscoTextField_widget.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String firstName = "";
  String lastName = "";
  bool _isLoading = false;

  Future<void> signIn(BuildContext context) async {
    if (_emailTextController.text.isEmpty ||
        _passwordTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill up all provided fields"),
        backgroundColor: Colors.purple,
      ));
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      Map<String, dynamic> dataMap = Map<String, dynamic>.from(
          userSnapshot.data() as Map<String, dynamic>);

      firstName = dataMap['firstName'];
      lastName = dataMap['lastName'];
      if (dataMap['accountType'] == "CLIENT") {
        if (userCredential.user!.emailVerified == false) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please verify your email before signing in')));
          setState(() {
            _isLoading = false;
          });
          await userCredential.user!.sendEmailVerification();
          _emailTextController.clear();
          _passwordTextController.clear();
          return;
        }
        _goToClientHomeScreen(context, userCredential.user!.uid);
      } else if (dataMap['accountType'] == "TRAINER") {
        _goToTrainerHomeScreen(context, userCredential.user!.uid);
      } else if (dataMap['accountType'] == "ADMIN") {
        _goToAdminHomeScreen(context);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid email or password: $error"),
        backgroundColor: Colors.purple,
      ));
      _emailTextController.clear();
      _passwordTextController.clear();
    }
  }

  void _goToClientHomeScreen(BuildContext context, String uid) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = docSnapshot.data();

    if (userData!['membershipStatus'] == 'UNPAID') {
      _emailTextController.clear();
      _passwordTextController.clear();
      FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your membership is expired. Please pay at the counter."),
        backgroundColor: Colors.purple,
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const ClientHomeScreen(),
      ));
    }
  }

  void _goToTrainerHomeScreen(BuildContext context, String uid) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = docSnapshot.data();

    if (userData!['isDeleted'] == true) {
      _emailTextController.clear();
      _passwordTextController.clear();
      FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your account has been deleted by the admin."),
        backgroundColor: Colors.purple,
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TrainerHomeScreen(
          uid: uid,
        ),
      ));
    }
  }

  void _goToAdminHomeScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AdminHomeScreen(),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    hexStringToColor("CB2B93"),
                    hexStringToColor("9546C4"),
                    hexStringToColor("5E61F4"),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).size.height * 0.1,
                    20,
                    0,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 100,
                        child: Image.asset('assets/images/fitnessco_logo.png'),
                      ),
                      const SizedBox(height: 100),
                      fitnesscoTextField(
                        "Enter Email Address",
                        Icons.email_outlined,
                        false,
                        _emailTextController,
                      ),
                      const SizedBox(height: 30),
                      fitnesscoTextField(
                        "Enter Password",
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                      ),
                      const SizedBox(height: 30),
                      ovalButton(context, "LOG IN", () => signIn(context)),
                      const SizedBox(height: 10),
                      _forgotPassword(context),
                      const SizedBox(height: 10),
                      _signUpOption(context),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextButton _forgotPassword(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen()));
        },
        child: const Text("Forgot your password? ",
            style: TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
                fontSize: 15)));
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
