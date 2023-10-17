import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_container_widget.dart';
import '../widgets/fitnessco_textfield_widget.dart';

class AddTrainerScreen extends StatefulWidget {
  const AddTrainerScreen({super.key});

  @override
  State<AddTrainerScreen> createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen> {
  bool _isLoading = false;
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  Future<void> _addNewTrainer() async {
    if (_idNumberController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailTextController.text.isEmpty ||
        _passwordTextController.text.isEmpty) {
      showErrorMessage(context, label: 'Please fill up all the fields');
      return;
    }
    if (_passwordTextController.text.length < 6) {
      showErrorMessage(context,
          label: 'Password must be at least six characters long');
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final currentAdmin = await getCurrentUserData();
      String adminEmail = currentAdmin['email'];
      String adminPassword = currentAdmin['password'];

      final newTrainerCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newTrainerCredential.user!.uid)
          .set({
        'idNumber': _idNumberController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'accountType': 'TRAINER',
        'isDeleted': false,
        'trainingRequests': [],
        'currentClients': [],
        'profileImageURL': '',
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

      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail, password: adminPassword);

      setState(() {
        _isLoading = false;
        _idNumberController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailTextController.clear();
        _passwordTextController.clear();
      });
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error creating new trainer: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: Center(
        child: futuraText('ADD NEW TRAINER', textStyle: blackBoldStyle()),
      )),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: stackedLoadingContainer(context, _isLoading, [
            userAuthBackgroundContainer(context,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 130),
                          roundedContainer(
                              color: Colors.white.withOpacity(0.8),
                              height: MediaQuery.of(context).size.height * 0.7,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _employeeID(),
                                    _firstName(),
                                    _lastName(),
                                    _emailAddress(),
                                    _password(),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              )),
                          _registerButton()
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          SizedBox(height: 85),
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                                'assets/images/fitnessco_logo_notext.png'),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ])),
    );
  }

  Widget _employeeID() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField(
            "Enter ID Number", TextInputType.number, _idNumberController,
            icon: Icons.person_outline));
  }

  Widget _firstName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField(
            "Enter First Name", TextInputType.name, _firstNameController,
            icon: Icons.person_outline));
  }

  Widget _lastName() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField(
            "Enter Last Name", TextInputType.name, _lastNameController,
            icon: Icons.person_outline));
  }

  Widget _emailAddress() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField("Enter Email Address",
            TextInputType.emailAddress, _emailTextController,
            icon: Icons.email));
  }

  Widget _password() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField(
            "Password", TextInputType.visiblePassword, _passwordTextController,
            icon: Icons.lock_outline));
  }

  Widget _registerButton() {
    return gradientOvalButton(
        label: 'ADD NEW TRAINER', width: 250, onTap: () => _addNewTrainer());
  }
}
