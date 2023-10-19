import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/prescribe_workout_screen.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_utils.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class TrainerScheduleScreen extends StatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> userDataList = [];
  DateTime _selectedDate = DateTime.now();
  List<dynamic> workoutsForSelectedDate = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getAllClientAppointments();
  }

  void _getAllClientAppointments() async {
    try {
      final trainerData = await getCurrentUserData();

      List<dynamic> clientUIDs = trainerData['currentClients'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: clientUIDs)
          .get();

      // THIS ITERATES THROUGH EVERY CLIENT
      for (var snapshot in querySnapshot.docs) {
        if (!snapshot.exists) {
          continue;
        }
        final clientData = snapshot.data() as Map<String, dynamic>;
        final clientPrescribedWorkouts =
            clientData['prescribedWorkouts'] as Map<dynamic, dynamic>;
        if (clientPrescribedWorkouts.isEmpty) {
          continue;
        }
        userDataList.add({'uid': snapshot.id, 'clientData': clientData});
        _lookForClients(_selectedDate);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      showErrorMessage(context,
          label: 'Error getting client appointments: $error');
    }
  }

  void _lookForClients(DateTime _selectedDate) {
    workoutsForSelectedDate.clear();
    for (var currentUser in userDataList) {
      final currentUserData =
          currentUser['clientData'] as Map<dynamic, dynamic>;
      final prescribedWorkouts =
          currentUserData['prescribedWorkouts'] as Map<dynamic, dynamic>;
      for (var prescribedWorkout in prescribedWorkouts.entries) {
        final workoutData = prescribedWorkout.value as Map<String, dynamic>;
        final workoutDate = (workoutData['workoutDate'] as Timestamp).toDate();
        if (_isDateEqual(_selectedDate, workoutDate)) {
          workoutsForSelectedDate.add({
            'uid': currentUser['uid'],
            'clientData': currentUserData,
            'workoutID': prescribedWorkout.key
          });
        }
      }
    }
    print('WORKOUTS FOR TODAY: $workoutsForSelectedDate');
  }

  bool _isDateEqual(DateTime _selectedDate, DateTime _workoutDate) {
    return _selectedDate.year == _workoutDate.year &&
        _selectedDate.month == _workoutDate.month &&
        _selectedDate.day == _workoutDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            toolbarHeight: 85,
            title: Center(
                child: futuraText("My Client Schedule",
                    textStyle: whiteBoldStyle(size: 25)))),
        body: stackedLoadingContainer(context, _isLoading, [
          viewTrainerBackgroundContainer(context,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _calendarCarousel(),
                      _selectedDateClientsContainer()
                    ],
                  ),
                ),
              ))
        ]));
  }

  Widget _calendarCarousel() {
    return CalendarCarousel(
        height: 375,
        width: MediaQuery.of(context).size.width * 0.9,
        weekendTextStyle: whiteBoldStyle(),
        daysTextStyle: whiteBoldStyle(),
        showOnlyCurrentMonthDate: true,
        daysHaveCircularBorder: true,
        headerTextStyle: TextStyle(
            color: CustomColors.purpleSnail,
            fontWeight: FontWeight.bold,
            fontSize: 20),
        weekdayTextStyle: GoogleFonts.cambay(textStyle: blackBoldStyle()),
        selectedDateTime: _selectedDate,
        todayButtonColor: CustomColors.nearMoon,
        todayBorderColor: CustomColors.nearMoon,
        selectedDayButtonColor: Colors.transparent,
        selectedDayBorderColor: Colors.transparent,
        leftButtonIcon: Transform.scale(
          scale: 1.5,
          child: Icon(
            Icons.arrow_circle_left_outlined,
            color: CustomColors.purpleSnail,
          ),
        ),
        rightButtonIcon: Transform.scale(
          scale: 1.5,
          child: Icon(
            Icons.arrow_circle_right_outlined,
            color: CustomColors.purpleSnail,
          ),
        ),
        isScrollable: false,
        onDayPressed: (selectedDate, _) {
          setState(() {
            _selectedDate = selectedDate;
            _lookForClients(_selectedDate);
          });
        },
        customDayBuilder: (isSelectable, index, isSelectedDay, isToday,
            isPrevMonthDay, textStyle, isNextMonthDay, isThisMonthDay, day) {
          return customDayWidget(isSelectedDay, day.day);
        });
  }

  Widget _selectedDateClientsContainer() {
    return workoutsForSelectedDate.isNotEmpty
        ? _clientsSpread()
        : SizedBox(
            height: 275,
            child: Center(
              child: futuraText('NO CLIENTS FOR THIS DAY',
                  textStyle: blackBoldStyle(size: 40)),
            ));
  }

  Widget _clientsSpread() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
          children: workoutsForSelectedDate.map((client) {
        final uid = client['uid'];
        final clientData = client['clientData'];
        final firstName = clientData['firstName'];
        final lastName = clientData['lastName'];
        final profileImageURL = clientData['profileImageURL'];
        final prescribedWorkouts =
            clientData['prescribedWorkouts'] as Map<dynamic, dynamic>;
        final workoutForToday = prescribedWorkouts[client['workoutID']];
        final workout = workoutForToday['workout'];
        final workoutDescription = workoutForToday['description'];
        return Padding(
          padding: EdgeInsets.all(10),
          child: roundedContainer(
              width: double.maxFinite,
              height: 130,
              color: CustomColors.love,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildProfileImage(
                          profileImageURL: profileImageURL, radius: 50),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          futuraText('$firstName $lastName',
                              textStyle: blackBoldStyle()),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: futuraText(workoutDescription),
                          ),
                          SizedBox(
                            height: 33,
                            child: ElevatedButton(
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PrescribeWorkoutScreen(
                                                clientUID: uid,
                                                dateTime: _selectedDate,
                                                currentWorkouts: workout,
                                                viewingSchedule: true,
                                                workoutID: client['workoutID'],
                                                description:
                                                    workoutDescription))),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: futuraText('VIEW WORKOUT',
                                    textStyle: whiteBoldStyle(size: 14))),
                          )
                        ],
                      )
                    ],
                  ))),
        );
      }).toList()),
    );
  }
}
