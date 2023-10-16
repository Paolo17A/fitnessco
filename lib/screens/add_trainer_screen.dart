// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/fitnessco_textfield_widget.dart';

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
        'trainingRequests': [],
        'currentClients': [],
        'profileImageURL': ''
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
                fitnesscoTextField("Enter ID Number", TextInputType.number,
                    _idNumberController,
                    icon: Icons.work),
                const SizedBox(height: 30),
                fitnesscoTextField(
                  "Enter First Name",
                  TextInputType.name,
                  _firstNameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 30),
                fitnesscoTextField(
                    "Enter Last Name", TextInputType.name, _lastNameController,
                    icon: Icons.person_outline),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Email Address",
                    TextInputType.emailAddress, _emailTextController,
                    icon: Icons.email),
                const SizedBox(height: 30),
                fitnesscoTextField("Enter Password",
                    TextInputType.visiblePassword, _passwordTextController,
                    icon: Icons.lock_outline),
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
