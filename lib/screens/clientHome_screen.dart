// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/allTrainers_screen.dart';
import 'package:fitnessco/screens/editClientProfile_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';
import 'chat_screen.dart';

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
  late String _membershipStatus;
  late bool _isConfirmed;
  late String _trainerUID;

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
        _membershipStatus = userData['membershipStatus'] as String;
        _isConfirmed = userData['isConfirmed'] as bool;
        _isLoading = false;
        _trainerUID = userData['currentTrainer'] as String;
      });
    }
  }

  void _onProfileUpdated(String newFirstName, String newLastName) {
    setState(() {
      _firstName = newFirstName;
      _lastName = newLastName;
    });
  }

  void _onTrainerRemoved() {
    Navigator.pop(context);
    setState(() {
      _isConfirmed = false;
      _trainerUID = '';
    });
  }

  void _goToAllTrainersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllTrainersScreen(
          isBeingViewedByAdmin: false,
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
                    height: 150,
                    color: Colors.purpleAccent.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child:
                                Image.asset('assets/images/defaultProfile.png'),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 25),
                              Text(
                                '$_firstName $_lastName',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "membershipStatus: $_membershipStatus",
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
                    child: Center(
                      child: GridView.count(
                        padding: EdgeInsets.all(screenSize.width * 0.05),
                        crossAxisCount: 2,
                        crossAxisSpacing: screenSize.width * 0.05,
                        mainAxisSpacing: screenSize.width * 0.05,
                        childAspectRatio: itemWidth / itemHeight,
                        shrinkWrap: true,
                        children: [
                          if (_isConfirmed)
                            squareIconButton_Widget(
                                context, 'Chat My Trainer', Icons.person, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          otherPersonUID: _trainerUID,
                                          isClient: true,
                                          onCallback: _onTrainerRemoved)));
                            })
                          else
                            squareIconButton_Widget(
                                context,
                                'View All Trainers',
                                Icons.people,
                                () => _goToAllTrainersScreen(context)),
                          squareIconButton_Widget(context,
                              'View My Workout Plan', Icons.list, () {}),
                          squareIconButton_Widget(
                              context,
                              'My Training Session',
                              Icons.fitness_center,
                              () {}),
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
                  ),
                  LogOutWidget(screenSize: screenSize)
                ],
              ),
            ),
          );
  }
}
