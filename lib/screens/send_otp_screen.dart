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
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSentToPhone = false;
  String _verificationCode = '';

  @override
  void initState() {
    super.initState();
  }

  void verifyPhoneNumber(String phoneNumber) async {
    if (_numberController.text.length != 10) {
      showErrorMessage(context,
          label: 'Your number must have exactly 10 digits');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    //FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+63$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        showErrorMessage(context, label: 'Error handling OTP: ${e.toString()}');
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationCode = verificationId;
          _isLoading = false;
          _otpSentToPhone = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future processSubmittedOTP() async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationCode,
        smsCode: _otpController.text,
      );
      await FirebaseAuth.instance.currentUser!
          .linkWithCredential(phoneAuthCredential);
      print('Phone number verified successfully');
      Navigator.of(context).pushNamed('/completeProfile');
    } catch (e) {
      showErrorMessage(context,
          label: 'Error signing in with code: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                                    _otpSentToPhone
                                        ? 'Enter the OTP sent to ${_numberController.text}'
                                        : 'Enter your phone number (format: 9*********)',
                                    style: blackBoldStyle(),
                                  ),
                                  const SizedBox(height: 30),
                                  if (!_otpSentToPhone)
                                    fitnesscoTextField(
                                      "Phone Number",
                                      TextInputType.number,
                                      _numberController,
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
                                  _otpSentToPhone ? "Verify OTP" : 'Send OTP',
                              width: 250,
                              onTap: () {
                                if (_otpSentToPhone) {
                                  processSubmittedOTP();
                                } else {
                                  verifyPhoneNumber(_numberController.text);
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
