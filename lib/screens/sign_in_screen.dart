import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/firebase_messaging_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/fitnessco_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_container_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool _isLoading = false;

  Future<void> signIn(BuildContext context) async {
    if (_emailTextController.text.isEmpty ||
        _passwordTextController.text.isEmpty) {
      showErrorMessage(context, label: 'Please fill up all provided fields');
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
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('email', _emailTextController.text);
      sharedPreferences.setString('password', _passwordTextController.text);
      final dataMap = await getCurrentUserData();

      String currentToken = await getToken();

      if (!dataMap.containsKey('pushTokens')) {
        updateCurrentUserData({
          'pushTokens': [currentToken]
        });
      } else {
        List<dynamic> allTokens = dataMap['pushTokens'];
        if (!allTokens.contains(currentToken)) {
          allTokens.add(currentToken);
          updateCurrentUserData({'pushTokens': allTokens});
        }
      }

      if (dataMap['accountType'] == "CLIENT") {
        //  The user's email has not yet been verified
        if (userCredential.user!.emailVerified == false) {
          //  The user's data in Firestore has a dateEmailVerificationSent paramter.
          if (dataMap.containsKey('dateEmailVerificationSent')) {
            DateTime dateEmailVerificationSent =
                (dataMap['dateEmailVerificationSent'] as Timestamp).toDate();
            if (DateTime.now().difference(dateEmailVerificationSent).inMinutes <
                50) {
              showErrorMessage(context,
                  label:
                      'Please check your email for the email verification link.');
              setState(() {
                _isLoading = false;
              });
            } else {
              showErrorMessage(context,
                  label:
                      'A new email verification link has been sent to your email.');
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .update({'dateEmailVerificationSent': DateTime.now()});
              await userCredential.user!.sendEmailVerification();
              setState(() {
                _isLoading = false;
              });
            }
          }
          //  A dateEmailVerificationSent parameter does NOT yet exist.
          else {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({'dateEmailVerificationSent': DateTime.now()});
            showErrorMessage(context,
                label:
                    'Please check your email for the email verification link.');
            await userCredential.user!.sendEmailVerification();
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        _goToClientHomeScreen();
      } else if (dataMap['accountType'] == "TRAINER") {
        _goToTrainerHomeScreen();
      } else if (dataMap['accountType'] == "ADMIN") {
        _goToAdminHomeScreen();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: "Error logging in: $error");
    }
  }

  void _goToClientHomeScreen() async {
    final userData = await getCurrentUserData();
    final expiryDate = (userData['expiryDate'] as Timestamp).toDate();
    if (!userData.containsKey('paymentInterval')) {
      await updateCurrentUserData({'paymentInterval': 'DAILY'});
    }

    if (userData['membershipStatus'] == 'UNPAID') {
      await FirebaseAuth.instance.signOut();
      showErrorMessage(context,
          label: "YOU ARE CURRENTLY UNPAID. PLEASE PAY FIRST AT THE COUNTER");
      setState(() {
        _isLoading = false;
      });
    } else if (userData['membershipStatus'] == 'PAID' &&
        DateTime.now().isAfter(expiryDate)) {
      showErrorMessage(context,
          label: "YOUR MEMBERSHIP HAS EXPIRED. PLEASE RENEW AT THE COUNTER");
      await updateCurrentUserData({'membershipStatus': 'UNPAID'});
      setState(() {
        _isLoading = false;
      });
    } else {
      if (userData.containsKey('accountInitialized') &&
          userData['accountInitialized'] == true) {
        Navigator.of(context).pushNamed('/clientHome');
      } else {
        await updateCurrentUserData({'accountInitialized': false});
        Navigator.of(context).pushNamed('/sendOTP');
      }
    }
  }

  void _goToTrainerHomeScreen() async {
    final userData = await getCurrentUserData();

    if (userData['isDeleted'] == true) {
      _emailTextController.clear();
      _passwordTextController.clear();
      FirebaseAuth.instance.signOut();
      showErrorMessage(context,
          label: "Your account has been deleted by the admin.");
      return;
    }
    if (!userData.containsKey('profileDetails')) {
      await updateCurrentUserData({
        'profileDetails': {
          'sex': '',
          'age': '',
          'contactNumber': '',
          'address': '',
          'certifications': [],
          'interests': [],
          'specialty': []
        },
        'email': _emailTextController.text,
        'password': _passwordTextController.text
      });
    }
    Navigator.of(context).pushNamed('/trainerHome');
  }

  void _goToAdminHomeScreen() {
    Navigator.of(context).pushNamed('/adminHome');
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
          child: stackedLoadingContainer(context, _isLoading, [
            SafeArea(
              child: welcomeBackgroundContainer(
                context,
                child: Column(
                  children: [
                    fitnesscoLogo(),
                    roundedContainer(
                        color: Colors.white.withOpacity(0.8),
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            fitnesscoTextField(
                                "Enter Email Address",
                                TextInputType.emailAddress,
                                _emailTextController,
                                icon: Icons.email_outlined),
                            _enterPassword(),
                            const SizedBox(height: 10),
                            _logInButton(),
                            _forgotPassword(context),
                            _signUpOption(context),
                          ]),
                        ))
                  ],
                ),
              ),
            )
          ])),
    );
  }

  Widget _enterPassword() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: fitnesscoTextField("Enter Password", TextInputType.visiblePassword,
          _passwordTextController,
          icon: Icons.lock_outline),
    );
  }

  Widget _logInButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: gradientOvalButton(
          label: 'LOG-IN', width: 250, onTap: () => signIn(context)),
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/forgotPassword'),
        child:
            futuraText("Forgot your password? ", textStyle: blackBoldStyle()));
  }

  TextButton _signUpOption(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/signUp'),
        child:
            futuraText("Don't have an account? ", textStyle: blackBoldStyle()));
  }
}
