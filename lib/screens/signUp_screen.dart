// ignore_for_file: file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp(BuildContext context) async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailTextController.text.isEmpty ||
        _passwordTextController.text.isEmpty ||
        _confirmPasswordTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill up all provided fields"),
        backgroundColor: Colors.purple,
      ));
      return;
    }
    if (_passwordTextController.text != _confirmPasswordTextController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.purple,
      ));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'accountType': 'CLIENT',
        'currentTrainer': '',
        'isConfirmed': false,
        'membershipStatus': 'UNPAID',
        'profileImageURL': '',
        'prescribedWorkout': {}
      });

      print("Success");
      _openHomeScreen(userCredential.user!.uid);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error ${error.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _openHomeScreen(String uid) {
    Navigator.pop(context);
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientHomeScreen(uid: uid)),
    );*/
  }

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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(children: [
          Container(
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
                    fitnesscoTextField("Enter First Name", Icons.person_outline,
                        false, _firstNameController),
                    const SizedBox(height: 30),
                    fitnesscoTextField("Enter Last Name", Icons.person_outline,
                        false, _lastNameController),
                    const SizedBox(height: 30),
                    fitnesscoTextField("Enter Email Address", Icons.email,
                        false, _emailTextController),
                    const SizedBox(height: 30),
                    fitnesscoTextField("Enter Password", Icons.lock_outline,
                        true, _passwordTextController),
                    const SizedBox(height: 40),
                    fitnesscoTextField("Confirm Password", Icons.lock_outline,
                        true, _confirmPasswordTextController),
                    const SizedBox(height: 40),
                    ovalButton(context, "REGISTER", () => _signUp(context)),
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
        ]),
      ),
    );
  }
}
