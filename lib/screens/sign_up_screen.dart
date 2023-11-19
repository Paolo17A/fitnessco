import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/fitnessco_textfield_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp(BuildContext context) async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailTextController.text.isEmpty ||
        _passwordTextController.text.isEmpty ||
        _confirmPasswordTextController.text.isEmpty) {
      showErrorMessage(context, label: "Please fill up all provided fields");
      return;
    }
    if (_passwordTextController.text != _confirmPasswordTextController.text) {
      showErrorMessage(context, label: "Passwords do not match");
      return;
    }
    if (_passwordTextController.text.length < 8) {
      showErrorMessage(context,
          label: 'Password must be at leat 8 characters long');
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'accountInitialized': false,
        'accountType': 'CLIENT',
        'currentTrainer': '',
        'isConfirmed': false,
        'membershipStatus': 'PAID',
        'profileImageURL': '',
        'prescribedWorkouts': {},
        'bmiHistory': [],
        'workoutHistory': [],
        'gymHistory': [],
        'expiryDate': DateTime.now().add(Duration(days: 1)),
        'dateEmailVerificationSent': DateTime.now(),
        'paymentInterval': 'DAILY',
        'pushTokens': [],
        'profileDetails': {
          'age': 0,
          'sex': '',
          'height': 0,
          'weight': 0,
          'workoutExperience': '',
          'workoutFrequency': 0,
          'sleepHours': 0,
          'workoutAvailability': '',
          'illnesses': '',
          'allergies': '',
          'recentlyDoctored': false,
          'injuries': '',
          'medications': '',
          'steroids': '',
          'foodDiet': '',
          'bodyConcerns': '',
          'muscleGoal': '',
          'dedicationSpan': '',
          'specialPlans': ''
        },
        'email': _emailTextController.text,
        'password': _passwordTextController.text
      });

      // Send email confirmation link to user
      await userCredential.user!.sendEmailVerification();

      showSuccessMessage(context,
          label:
              'A VERIFICATION LINK HAS BEEN SENT TO YOUR EMAIL. PLEASE CHECK TO VERIFY YOUR ACCOUNT',
          onPress: () => _goToLoginScreen());
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: error.toString());
    }
  }

  void _goToLoginScreen() {
    setState(() {
      _isLoading = false;
    });
    _emailTextController.clear();
    _passwordTextController.clear();
    _confirmPasswordTextController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    Navigator.of(context).pushNamed('/signIn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
              child: stackedLoadingContainer(context, _isLoading, [
            userAuthBackgroundContainer(context,
                child: Stack(
                  children: [
                    Center(
                      child: roundedContainer(
                          color: Colors.white.withOpacity(0.8),
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _firstName(),
                                _lastName(),
                                _emailAddress(),
                                _password(),
                                _confirmPassword(),
                                const SizedBox(height: 40),
                                _registerButton()
                              ],
                            ),
                          )),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                              'assets/images/fitnessco_logo_notext.png'),
                        ),
                      ),
                    )
                  ],
                )),
          ]))),
    );
  }

  Widget _firstName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: fitnesscoTextField(
            "Enter First Name", TextInputType.name, _firstNameController,
            icon: Icons.person_outline));
  }

  Widget _lastName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: fitnesscoTextField(
            "Enter Last Name", TextInputType.name, _lastNameController,
            icon: Icons.person_outline));
  }

  Widget _emailAddress() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: fitnesscoTextField("Enter Email Address",
            TextInputType.emailAddress, _emailTextController,
            icon: Icons.email));
  }

  Widget _password() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: fitnesscoTextField(
            "Password", TextInputType.visiblePassword, _passwordTextController,
            icon: Icons.lock_outline));
  }

  Widget _confirmPassword() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: fitnesscoTextField("Confirm Password",
            TextInputType.visiblePassword, _confirmPasswordTextController,
            icon: Icons.lock_outline));
  }

  Widget _registerButton() {
    return gradientOvalButton(
        label: 'REGISTER', width: 250, onTap: () => _signUp(context));
  }
}
