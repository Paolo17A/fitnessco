import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../widgets/FitnesscoTextField_widget.dart';
import '../widgets/OvalButton_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final TextEditingController _emailTextController = TextEditingController();

  void _sendEmailReset(BuildContext context) async {
    _isLoading = true;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_emailTextController.text.isEmpty ||
        !_emailTextController.text.contains('@') ||
        !_emailTextController.text.contains('com')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid email address"),
        backgroundColor: Colors.purple,
      ));
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailTextController.text.trim());

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Reset Password Email Sent Successfully!')));
      navigator.pop();
    } catch (error) {
      _isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Error Sending Reset Password Email: ${error.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
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
                    fitnesscoTextField("Enter your email address",
                        Icons.person_outline, false, _emailTextController),
                    const SizedBox(height: 30),
                    ovalButton(context, "RESET PASSWORD",
                        () => _sendEmailReset(context)),
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
