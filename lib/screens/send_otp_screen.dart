import 'dart:math';

import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../widgets/fitnessco_textfield_widget.dart';
import '../widgets/custom_button_widgets.dart';

class SendOTPScreen extends StatefulWidget {
  const SendOTPScreen({super.key});

  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSentToEmail = false;
  String sentOTP = '';

  @override
  void initState() {
    super.initState();
  }

  void sendOTPToEmail() async {
    if (_emailController.text != FirebaseAuth.instance.currentUser!.email) {
      showErrorMessage(context, label: 'Please enter YOUR email address');
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      Random rand = new Random();
      int otp = rand.nextInt(999999);
      sentOTP = otp.toString();
      await EmailJS.send(
          'service_0qlz3p8',
          'template_lheagkb',
          {'OTP': sentOTP, 'to_email': _emailController.text},
          Options(
              publicKey: 'WvT2mxhjyZepCXb9u',
              privateKey: 'CIm00txRTKaizbXd5T0os'));
      setState(() {
        _isLoading = false;
        _otpSentToEmail = true;
      });
    } catch (error) {
      showErrorMessage(context, label: 'Error sending OTP to email" $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future processSubmittedOTP() async {
    if (sentOTP == _otpController.text) {
      print('Phone number verified successfully');
      Navigator.of(context).pushNamed('/completeProfile');
    } else {
      showErrorMessage(context, label: 'Incorrect OTP');
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
                                    _otpSentToEmail
                                        ? 'Enter the OTP sent to ${_emailController.text}'
                                        : 'Re-enter your email address',
                                    style: blackBoldStyle(),
                                  ),
                                  const SizedBox(height: 30),
                                  if (!_otpSentToEmail)
                                    fitnesscoTextField(
                                      "Email Address",
                                      TextInputType.emailAddress,
                                      _emailController,
                                      icon: Icons.email,
                                    )
                                  else
                                    Pinput(
                                        length: 6, controller: _otpController),
                                ],
                              ),
                            ),
                          ),
                          gradientOvalButton(
                              label:
                                  _otpSentToEmail ? "Verify OTP" : 'Send OTP',
                              width: 250,
                              onTap: () {
                                if (_otpSentToEmail) {
                                  processSubmittedOTP();
                                } else {
                                  sendOTPToEmail();
                                }
                              })
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
