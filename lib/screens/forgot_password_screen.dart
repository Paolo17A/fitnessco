import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/fitnessco_textfield_widget.dart';
import '../widgets/custom_button_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final TextEditingController _emailTextController = TextEditingController();

  void _sendEmailReset() async {
    _isLoading = true;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_emailTextController.text.isEmpty ||
        !_emailTextController.text.contains('@') ||
        !_emailTextController.text.contains('com')) {
      showErrorMessage(context, label: "Please enter a valid email address");
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailTextController.text.trim());

      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Reset Password Email Sent Successfully!')));
      navigator.pop();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context,
          label: 'Error Sending Reset Password Email: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: stackedLoadingContainer(context, _isLoading, [
          SingleChildScrollView(
            child: userAuthBackgroundContainer(
              context,
              child: Stack(
                children: [
                  Center(
                    child: roundedContainer(
                      color: Colors.white.withOpacity(0.8),
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.2),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Text(
                                    'RESET PASSWORD',
                                    style: blackBoldStyle(),
                                  ),
                                  const SizedBox(height: 30),
                                  fitnesscoTextField(
                                    "ENTER EMAIL",
                                    TextInputType.emailAddress,
                                    _emailTextController,
                                    icon: Icons.email,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          gradientOvalButton(
                              label: "RESET PASSWORD",
                              width: 250,
                              onTap: _sendEmailReset)
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                            'assets/images/fitnessco_logo_notext.png'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ])),
      ),
    );
  }
}
