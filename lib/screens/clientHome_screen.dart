// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/allTrainers_screen.dart';
import 'package:fitnessco/screens/editClientProfile_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';

class ClientHomeScreen extends StatefulWidget {
  final String uid;

  const ClientHomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;
  late String _firstName;
  late String _lastName;

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

  void _goToAllTrainersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllTrainersScreen(
          showActions: false,
        ),
      ),
    );
  }

  void _goToEditClientProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClientProfile(
          uid: widget.uid,
          onProfileUpdated: _onProfileUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double itemWidth = (screenSize.width - 60) / 2;
    final double itemHeight = itemWidth * 0.8;
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
                              const Text(
                                "membershipStatus",
                                style: TextStyle(
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
                    child: GridView.count(
                      padding: EdgeInsets.all(screenSize.width * 0.05),
                      crossAxisCount: 2,
                      crossAxisSpacing: screenSize.width * 0.05,
                      mainAxisSpacing: screenSize.width * 0.05,
                      childAspectRatio: itemWidth / itemHeight,
                      children: [
                        squareIconButton_Widget(
                            context,
                            'View All Trainers',
                            Icons.people,
                            () => _goToAllTrainersScreen(context)),
                        squareIconButton_Widget(
                            context, 'View My Workout Plan', Icons.list, () {}),
                        squareIconButton_Widget(context, 'My Training Session',
                            Icons.fitness_center, () {}),
                        squareIconButton_Widget(
                            context, 'Workout History', Icons.history, () {}),
                        squareIconButton_Widget(
                            context,
                            'Edit Profile',
                            Icons.edit,
                            () => _goToEditClientProfileScreen(context)),
                        squareIconButton_Widget(
                            context, 'Settings', Icons.settings, () {}),
                      ],
                    ),
                  ),
                  LogOutWidget(screenSize: screenSize)
                ],
              ),
            ),
          );
  }
}
