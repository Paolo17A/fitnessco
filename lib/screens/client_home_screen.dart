import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/screens/start_workout_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/utils/quit_dialogue_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/home_app_bar_widget.dart';
import 'package:flutter/material.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => ClientHomeScreenState();
}

class ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;

  String _firstName = '';
  String _lastName = '';
  bool _isConfirmed = false;
  String _trainerUID = '';
  String _profileImageURL = '';
  String _paymentInterval = '';
  Map<dynamic, dynamic> _profileDetails = {};
  List<dynamic> _bmiHistory = [];
  bool _hasWorkoutToday = false;
  bool _workoutTodayFinished = false;
  Map<dynamic, dynamic> workoutForToday = {};
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await getCurrentUserData();
      setState(() {
        _firstName = userData['firstName'] as String;
        _lastName = userData['lastName'] as String;
        _isConfirmed = userData['isConfirmed'] as bool;
        _trainerUID = userData['currentTrainer'] as String;
        _profileImageURL = userData['profileImageURL'] as String;
        _paymentInterval = userData['paymentInterval'] as String;
        _profileDetails = userData['profileDetails'];
        _bmiHistory = userData['bmiHistory'] as List<dynamic>;

        //  WORKOUT PRESCRIPTIONS
        final workoutPrescriptions =
            userData['prescribedWorkouts'] as Map<dynamic, dynamic>;
        for (var prescribedWorkout in workoutPrescriptions.entries) {
          final workoutData = prescribedWorkout.value as Map<String, dynamic>;
          final workoutDate =
              (workoutData['workoutDate'] as Timestamp).toDate();
          if (_isDateEqual(DateTime.now(), workoutDate)) {
            _hasWorkoutToday = true;
            workoutForToday = workoutData['workout'];
            break;
          }
        }

        final workoutHistory = userData['workoutHistory'] as List<dynamic>;
        for (var historyEntry in workoutHistory) {
          final historyEntryDate =
              (historyEntry['dateTime'] as Timestamp).toDate();
          if (_isDateEqual(DateTime.now(), historyEntryDate)) {
            _workoutTodayFinished = true;
            break;
          }
        }
        _isLoading = false;
      });
    } catch (error) {
      showErrorMessage(context, label: 'Error getting client data.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isDateEqual(DateTime _selectedDate, DateTime _workoutDate) {
    return _selectedDate.year == _workoutDate.year &&
        _selectedDate.month == _workoutDate.month &&
        _selectedDate.day == _workoutDate.day;
  }

  void _goToAllTrainersScreen() {
    Navigator.of(context).pushNamed('/viewAllTrainers');
  }

  void _goToEditClientProfileScreen() {
    Navigator.of(context).pushNamed('/editClientProfile');
  }

  void _goToStartWorkoutScreen() {
    if (!_hasWorkoutToday) {
      showErrorMessage(context, label: 'You have no assigned workout today.');
      return;
    } else if (_workoutTodayFinished) {
      showErrorMessage(context, label: 'You already did today\'s workout.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            StartWorkoutScreen(workoutForToday: workoutForToday)));
  }

  void _goToClientWorkoutScreen() {
    if (_trainerUID == '') {
      showErrorMessage(context, label: 'You have no assigned trainer yet');

      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ClientWorkoutsScreen(
          clientUID: FirebaseAuth.instance.currentUser!.uid),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => displayQuitDialogue(context),
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: homeAppBar(context, title: _profileInfoHeader(),
                    onRefresh: () {
                  setState(() {
                    _isLoading = true;
                  });
                  fetchUserData();
                }),
                body: switchedLoadingContainer(
                    _isLoading,
                    homeBackgroundContainer(context,
                        child: SafeArea(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              _profileImage(),
                              SizedBox(height: 25),
                              _diagonalDataContent(),
                              _homeRowContainers(),
                              _trainingAndProfileTabs()
                            ])))))));
  }

  Widget _profileInfoHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      //SizedBox(width: MediaQuery.of(context).size.width * 0.1),
      Column(children: [
        futuraText('$_firstName $_lastName', textStyle: blackBoldStyle()),
        futuraText(_paymentInterval, textStyle: blackBoldStyle(size: 15))
      ])
    ]);
  }

  Widget _profileImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: buildProfileImage(profileImageURL: _profileImageURL, radius: 50),
    );
  }

  Widget _diagonalDataContent() {
    String ageFormatted = 'AGE:  ${_profileDetails['age']}';
    String currentBMIFormatted =
        'CURRENT BMI: ${_bmiHistory.isNotEmpty ? _bmiHistory[_bmiHistory.length - 1]['bmiValue'] : '0.0'}';
    return Column(children: [
      Container(
        height: 20,
        width: 200,
        child: futuraText(ageFormatted, textStyle: blackBoldStyle(size: 15)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: futuraText(currentBMIFormatted,
            textStyle: blackBoldStyle(size: 15)),
      ),
      GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/gymRates'),
        child:
            futuraText('VIEW GYM RATES', textStyle: whiteBoldStyle(size: 15)),
      )
    ]);
  }

  Widget _homeRowContainers() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Container(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(children: [
                  homeRowContainer(
                      iconPath: 'assets/images/icons/view_trainers.png',
                      imageScale: 60,
                      label: 'View All Trainers',
                      onPress: () => _goToAllTrainersScreen()),
                  homeRowContainer(
                      iconPath: 'assets/images/icons/view_workouts_plan.png',
                      imageScale: 60,
                      label: 'View My Workout Plan',
                      onPress: () => _goToClientWorkoutScreen()),
                  homeRowContainer(
                      iconPath: 'assets/images/icons/personal_history.png',
                      imageScale: 60,
                      label: 'Personal History',
                      onPress: () =>
                          Navigator.of(context).pushNamed('/workoutHistory')),
                ]))));
  }

  Widget _trainingAndProfileTabs() {
    return Column(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TabBar(tabs: [
          Tab(
              child: futuraText('MY TRAINING SESSION',
                  textStyle: blackBoldStyle(size: 12))),
          Tab(
            child: futuraText('PROFILE DESCRIPTION',
                textStyle: blackBoldStyle(size: 12)),
          )
        ]),
      ),
      Container(
        height: 200,
        child: TabBarView(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Image.asset(
                              _isConfirmed
                                  ? 'assets/images/icons/has_trainer.png'
                                  : 'assets/images/icons/no_trainer.png',
                              height: 150,
                            )),
                        if (!_isConfirmed)
                          Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 100,
                              child: futuraText(
                                  'YOU HAVE NO TRAINERS. GET A TRAINING REQUEST FIRST'))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: ElevatedButton(
                        onPressed: _isConfirmed
                            ? () => _goToStartWorkoutScreen()
                            : null,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: CustomColors.nearMoon),
                        child: futuraText('START WORKOUT SESSION',
                            textStyle: whiteBoldStyle(size: 15))),
                  )
                ],
              ),
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 150,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Image.asset(
                                  'assets/images/icons/edit_profile_description.png',
                                  height: 150)),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  futuraText('$_firstName $_lastName',
                                      textStyle: blackBoldStyle()),
                                  futuraText('${_profileDetails['height']} cm',
                                      textStyle: blackBoldStyle(size: 15)),
                                  futuraText(
                                      'Illnesses: ${_profileDetails['illnesses']}',
                                      textStyle: blackBoldStyle(size: 15)),
                                  futuraText(
                                      '${_profileDetails['workoutExperience']}',
                                      textStyle: blackBoldStyle(size: 15)),
                                ],
                              ))
                        ]),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: ElevatedButton(
                        onPressed: () => _goToEditClientProfileScreen(),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: CustomColors.purpleSnail),
                        child: futuraText('UPDATE YOUR PROFILE NOW',
                            textStyle: whiteBoldStyle(size: 15))),
                  )
                ],
              ))
        ]),
      )
    ]);
  }
}
