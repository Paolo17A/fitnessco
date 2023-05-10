// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/editTrainerProfile_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';

class TrainerHomeScreen extends StatefulWidget {
  final String uid;
  const TrainerHomeScreen({super.key, required this.uid});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  final double _buttonWidth = 250;

  bool _isLoading = true;
  late String _firstName;
  late String _lastName;
  late String _idNumber;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    final userData = docSnapshot.data();
    if (userData != null) {
      setState(() {
        _firstName = userData['firstName'] as String;
        _lastName = userData['lastName'] as String;
        _idNumber = userData['idNumber'] as String;
        _isLoading = false;
      });
    }
  }

  void _onProfileUpdated(String newFirstName, String newLastName) {
    setState(() {
      _firstName = newFirstName;
      _lastName = newLastName;
    });
  }

  void _goToEditTrainerProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTrainerProfile(
          uid: widget.uid,
          onProfileUpdated: _onProfileUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return _isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            body: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.red,
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                '$_firstName $_lastName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "ID Number: $_idNumber",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            squareIconButton_Widget(
                                context,
                                'View My Clients',
                                Icons.people,
                                buttonWidth: _buttonWidth,
                                () {}),
                            squareIconButton_Widget(
                                context,
                                'View My Schedule',
                                Icons.calendar_month,
                                buttonWidth: _buttonWidth,
                                () {}),
                            squareIconButton_Widget(
                                context,
                                'Edit Profile',
                                Icons.edit,
                                buttonWidth: _buttonWidth,
                                () => _goToEditTrainerProfileScreen(context)),
                            squareIconButton_Widget(
                                context,
                                'Settings',
                                Icons.settings,
                                buttonWidth: _buttonWidth,
                                () {}),
                            LogOutWidget(screenSize: screenSize)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
