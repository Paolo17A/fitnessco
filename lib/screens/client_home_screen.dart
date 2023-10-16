// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/all_trainers_screen.dart';
import 'package:fitnessco/screens/bmi_history_screen.dart';
import 'package:fitnessco/screens/camera_workout_screen.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/screens/edit_client_profile_screen.dart';
import 'package:fitnessco/screens/workout_history_screen.dart';
import 'package:fitnessco/utils/gym_rates_dialogue_util.dart';
import 'package:fitnessco/utils/quit_dialogue_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/home_app_bar_widget.dart';
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
  late bool _isConfirmed;
  late String _trainerUID;
  late String _profileImageURL;
  late bool _hasPrescribedWorkout;
  late String _paymentInterval;

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
        _isConfirmed = userData['isConfirmed'] as bool;
        _isLoading = false;
        _trainerUID = userData['currentTrainer'] as String;
        _hasPrescribedWorkout =
            (userData['prescribedWorkout'] as Map<String, dynamic>).isNotEmpty;
        _profileImageURL = userData['profileImageURL'] as String;
        _paymentInterval = userData['paymentInterval'] as String;
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
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const AllTrainersScreen(
              isBeingViewedByAdmin: false,
            )));
  }

  void _goToEditClientProfileScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const EditClientProfile(),
    ));
  }

  void _goToClientWorkoutScreen(BuildContext context) {
    if (_trainerUID == '') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have no assigned trainer yet')));
      return;
    }
    if (_hasPrescribedWorkout == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your trainer has not yet prescribed a workout')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ClientWorkoutsScreen(
          clientUID: FirebaseAuth.instance.currentUser!.uid),
    ));
  }

  void _goToCameraWorkoutScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const CameraWorkoutScreen(),
    ));
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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            ListTile(
                leading: const Icon(Icons.list),
                title: const Text('BMI'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BMIHistoryScreen()));
                }),
            ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Workout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WorkoutHistoryScreen()));
                })
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double itemWidth = (screenSize.width - 60) / 2;
    final double itemHeight = itemWidth * 0.8;
    return WillPopScope(
        onWillPop: () => displayQuitDialogue(context),
        child: Scaffold(
            appBar: homeAppBar(context),
            body: RefreshIndicator(
                onRefresh: _refreshData,
                child: SafeArea(
                  child: switchedLoadingContainer(
                      _isLoading,
                      homeBackgroundContainer(
                        context,
                        child: Container(
                            color: Colors.white,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 150,
                                      color:
                                          Colors.purpleAccent.withOpacity(0.1),
                                      child: Padding(
                                          padding: EdgeInsets.all(
                                              screenSize.width * 0.04),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                _buildProfileImage(),
                                                Column(children: [
                                                  //const SizedBox(height: 25),
                                                  Text(
                                                    '$_firstName $_lastName',
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    "Payment Plan: $_paymentInterval",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        final gymRates =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'gym_settings')
                                                                .doc('settings')
                                                                .get();
                                                        displayGymRates(context,
                                                            gymRates.data()!);
                                                      },
                                                      child: Text(
                                                          'VIEW GYM RATES',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900))),
                                                ])
                                              ]))),
                                  Center(
                                      child: GridView.count(
                                          padding: EdgeInsets.all(
                                              screenSize.width * 0.05),
                                          crossAxisCount: 2,
                                          crossAxisSpacing:
                                              screenSize.width * 0.05,
                                          mainAxisSpacing:
                                              screenSize.width * 0.05,
                                          childAspectRatio:
                                              itemWidth / itemHeight,
                                          shrinkWrap: true,
                                          children: [
                                        if (_isConfirmed)
                                          squareIconButton_Widget(
                                              context,
                                              'Chat My Trainer',
                                              Icons.person, () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                            otherPersonUID:
                                                                _trainerUID,
                                                            isClient: true,
                                                            onCallback:
                                                                _onTrainerRemoved)));
                                          })
                                        else
                                          squareIconButton_Widget(
                                              context,
                                              'View All Trainers',
                                              Icons.people,
                                              () => _goToAllTrainersScreen(
                                                  context)),
                                        squareIconButton_Widget(
                                            context,
                                            'View My Workout Plan',
                                            Icons.list,
                                            () => _goToClientWorkoutScreen(
                                                context)),
                                        squareIconButton_Widget(
                                            context,
                                            'My Training Session',
                                            Icons.fitness_center,
                                            () => _goToCameraWorkoutScreen(
                                                context)),
                                        squareIconButton_Widget(
                                            context,
                                            'Personal History',
                                            Icons.history, () {
                                          _settingModalBottomSheet(context);
                                        })
                                      ])),
                                  squareIconButton_Widget(
                                      context,
                                      'Profile Settings',
                                      Icons.edit,
                                      () => _goToEditClientProfileScreen(
                                          context)),
                                  const SizedBox(height: 100),
                                  LogOutWidget(screenSize: screenSize)
                                ])),
                      )),
                ))));
  }
}
