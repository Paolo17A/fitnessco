// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../widgets/OvalButton_widget.dart';
import '../widgets/FitnesscoTextField_widget.dart';

class AddTrainerScreen extends StatefulWidget {
  const AddTrainerScreen({super.key});

  @override
  State<AddTrainerScreen> createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen> {
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'idNumber': _idNumberController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'accountType': 'TRAINER',
        'isDeleted': false,
        'trainingRequests': []
      });
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error ${error.toString()}"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        //backgroundColor: Colors.pinkAccent,
        //elevation: 0,
        title: const Text(
          "New Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        //color: Colors.purpleAccent.withOpacity(0.3),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93").withOpacity(0.5),
            hexStringToColor("9546C4").withOpacity(0.5),
            hexStringToColor("5E61F4").withOpacity(0.5)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(
              children: [
                fitnesscoTextField(
                    "Enter ID Number", Icons.work, false, _idNumberController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter First Name", Icons.person_outline,
                    false, _firstNameController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Last Name", Icons.person_outline,
                    false, _lastNameController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Email Address", Icons.email, false,
                    _emailTextController),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 40),
                ovalButton(context, "ADD NEW TRAINER", () => _signUp(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
