import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/firebase_messaging_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_container_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  String? email;
  String? password;
  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  Future getSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    email = preferences.getString('email');
    password = preferences.getString(('password'));
    if (email == null || password == null) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);

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
        if (userCredential.user!.emailVerified == false) {
          showErrorMessage(context,
              label: 'Please verify your email before signing in');
          setState(() {
            _isLoading = false;
          });
          await userCredential.user!.sendEmailVerification();
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
      showErrorMessage(context,
          label: 'Error logging in automatically: $error');
      setState(() {
        _isLoading = false;
      });
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
        //FirebaseAuth.instance.currentUser!.updatePhoneNumber(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode).);
        Navigator.of(context).pushNamed('/completeProfile');
      }
    }
  }

  void _goToTrainerHomeScreen() async {
    final userData = await getCurrentUserData();

    if (userData['isDeleted'] == true) {
      FirebaseAuth.instance.signOut();
      showErrorMessage(context,
          label: "Your account has been deleted by the admin.");
      return;
    }

    Navigator.of(context).pushNamed('/trainerHome');
  }

  void _goToAdminHomeScreen() {
    Navigator.of(context).pushNamed('/adminHome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: stackedLoadingContainer(context, _isLoading, [
      SafeArea(
          child: welcomeBackgroundContainer(context,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/fitnessco_logo.png'),
                    roundedContainer(
                        color: Colors.white.withOpacity(0.8),
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: futuraText('WELCOME',
                                    textStyle: blackBoldStyle(size: 24)),
                              ),
                              gradientOvalButton(
                                  label: 'Create Your Account',
                                  width: 250,
                                  height: 70,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/signUp')),
                              const SizedBox(height: 50),
                              _alreadyHaveAccount(context)
                            ],
                          ),
                        ))
                  ]))),
    ]));
  }

  Widget _alreadyHaveAccount(BuildContext context) {
    return Column(
      children: [
        futuraText('Already have an account?',
            textStyle: blackBoldStyle(size: 18)),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/signIn'),
            child: Text('Sign in Here')),
        const SizedBox(height: 15)
      ],
    );
  }
}
