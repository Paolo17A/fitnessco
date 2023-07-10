// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/allTrainers_screen.dart';
import 'package:fitnessco/screens/editClientProfile_screen.dart';
import 'package:fitnessco/utils/quit_dialogue_util.dart';
import 'package:flutter/material.dart';

import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';
import 'chat_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => ClientHomeScreenState();
}

class ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;
  late String _firstName;
  late String _lastName;
  late String _membershipStatus;
  late bool _isConfirmed;
  late String _trainerUID;
  late String _profileImageURL;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
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

    final String profileImageURL = userData!['profileImageURL'] as String;
    if (profileImageURL.isNotEmpty) {
      setState(() {
        _profileImageURL = profileImageURL;
      });
    }
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
        builder: (context) => const EditClientProfile(),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImageURL != '') {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_profileImageURL),
      );
    } else {
      return const CircleAvatar(radius: 50, child: Icon(Icons.person));
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double itemWidth = (screenSize.width - 60) / 2;
    final double itemHeight = itemWidth * 0.8;
    return WillPopScope(
      onWillPop: () => displayQuitDialogue(context),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
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
                              _buildProfileImage(),
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
                                    context, 'Chat My Trainer', Icons.person,
                                    () {
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
                              squareIconButton_Widget(context,
                                  'Workout History', Icons.history, () {}),
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
        ),
      ),
    );
  }
}
