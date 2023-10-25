import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/prescribe_workout_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_messaging_util.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/muscle_audio_util.dart';
import 'package:fitnessco/utils/workout_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/fitnessco_textfield_widget.dart';
import 'package:fitnessco/widgets/navigation_bar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class ClientWorkoutsScreen extends StatefulWidget {
  final String clientUID;
  const ClientWorkoutsScreen({Key? key, required this.clientUID})
      : super(key: key);

  @override
  ClientWorkoutsScreenState createState() => ClientWorkoutsScreenState();
}

class ClientWorkoutsScreenState extends State<ClientWorkoutsScreen> {
  bool _isLoading = true;
  bool _isTrainer = false;
  final workoutDescriptionController = TextEditingController();
  Map<String, dynamic> prescribedWorkouts = {};
  Map<String, dynamic> appointment = {};
  DateTime _selectedDate = DateTime.now();
  Map<dynamic, dynamic> _selectedDateWorkout = {};
  String workoutID = '';

  @override
  void initState() {
    super.initState();
    _getPrescribedWorkout();
  }

  void _getPrescribedWorkout() async {
    try {
      final clientUser = await getThisUserData(widget.clientUID);
      final clientUserData = clientUser.data() as Map<dynamic, dynamic>;

      prescribedWorkouts = clientUserData['prescribedWorkouts'];
      _isTrainer = widget.clientUID != FirebaseAuth.instance.currentUser!.uid;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error getting client\'s prescribed workout: ${error.toString()}')));
    }
  }

  void _goToPrescribeWorkoutScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PrescribeWorkoutScreen(
            clientUID: widget.clientUID,
            dateTime: _selectedDate,
            currentWorkouts: _selectedDateWorkout,
            workoutID: workoutID,
            viewingSchedule: false,
            description: workoutDescriptionController.text.trim())));
  }

  bool _dateHasWorkout(DateTime _selectedDate) {
    for (var prescribedWorkout in prescribedWorkouts.entries) {
      final workoutData = prescribedWorkout.value as Map<String, dynamic>;
      final workoutDate = (workoutData['workoutDate'] as Timestamp).toDate();
      if (_isDateEqual(_selectedDate, workoutDate)) {
        workoutDescriptionController.text = workoutData['description'];
        _selectedDateWorkout = workoutData['workout'];
        workoutID = prescribedWorkout.key;
        return true;
      }
    }
    workoutID = '';
    workoutDescriptionController.text = '';
    _selectedDateWorkout = {};
    return false;
  }

  bool isTodayOrFutureDate(DateTime date) {
    DateTime currentDate = DateTime.now();

    // Remove the time portion from both dates to compare only the dates
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime inputDateWithoutTime = DateTime(date.year, date.month, date.day);

    // Check if the input date is today or a future date
    return inputDateWithoutTime.isAfter(currentDateWithoutTime) ||
        inputDateWithoutTime.isAtSameMomentAs(currentDateWithoutTime);
  }

  Future _removeSelectedWorkout(DateTime _selectedDate) async {
    final getUserData = await getThisUserData(widget.clientUID);

    for (var prescribedWorkout in prescribedWorkouts.entries) {
      final workoutData = prescribedWorkout.value as Map<String, dynamic>;
      final workoutDate = (workoutData['workoutDate'] as Timestamp).toDate();
      if (_isDateEqual(_selectedDate, workoutDate)) {
        prescribedWorkouts.remove(prescribedWorkout.key);
        await updateThisUserData(
            widget.clientUID, {'prescribedWorkouts': prescribedWorkouts});
        List<dynamic> pushTokens = getUserData.data()!['pushTokens'];
        for (var token in pushTokens) {
          await FirebaseMessagingUtil.sendRemovedWorkoutNotif(
              token, workoutData['description'], _selectedDate);
        }
        Navigator.of(context).pop();
        _getPrescribedWorkout();
        break;
      }
    }
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
            toolbarHeight: 105,
            title: Center(
                child: futuraText(
                    _isTrainer ? "Client Workout Plan" : "My Workout Plan",
                    textStyle: whiteBoldStyle(size: 25)))),
        bottomNavigationBar:
            _isTrainer ? null : clientNavBar(context, currentIndex: 1),
        body: switchedLoadingContainer(
          _isLoading,
          viewTrainerBackgroundContainer(
            context,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(children: [
                  _calendarCarousel(),
                  _workoutDescription(),
                  _workoutEntryContainer()
                ]),
              ),
            ),
          ),
        ));
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
          });
        },
        onDayLongPressed: (day) {
          if (!_isTrainer || !isTodayOrFutureDate(day)) {
            return;
          }
          setState(() {
            _selectedDate = day;
          });

          showSelectedDateOptions(context,
              hasWorkout: _dateHasWorkout(day),
              onSelectedPrescribe: _goToPrescribeWorkoutScreen,
              onSelectedDelete: () => _removeSelectedWorkout(day));
        },
        customDayBuilder: (isSelectable, index, isSelectedDay, isToday,
            isPrevMonthDay, textStyle, isNextMonthDay, isThisMonthDay, day) {
          return customDayWidget(isSelectedDay, day.day);
        });
  }

  Widget _workoutDescription() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: fitnesscoTextField(
          '', TextInputType.text, workoutDescriptionController,
          typeColor: Colors.black, isEditable: false),
    );
  }

  Widget _workoutEntryContainer() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: _dateHasWorkout(_selectedDate)
                ? _workoutSpread()
                : futuraText('NO ASSIGNED WORKOUT FOR THIS DATE',
                    textStyle: blackBoldStyle(size: 35))),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1)
      ],
    );
  }

  Widget _workoutSpread() {
    return Container(
      child: Column(
          //  THIS MAPS OUT ALL THE MUSCLES
          children: _selectedDateWorkout.entries.map((muscle) {
        final workouts = muscle.value as Map<dynamic, dynamic>;
        return Column(
          children: workouts.entries.map((workout) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onLongPress: () {
                  if (!_isTrainer) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: CustomColors.plasmaTrail,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/gifs/${workout.key}.gif'),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: futuraText(workout.key,
                                            textStyle:
                                                whiteBoldStyle(size: 30)),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: futuraText(
                                              getWorkoutIntro(workout.key),
                                              textStyle:
                                                  whiteBoldStyle(size: 15)))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  }
                },
                child: Container(
                    width: double.maxFinite,
                    height: 100,
                    color: CustomColors.love,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              height: 75,
                              width: 75,
                              color: Colors.white,
                              child: Image.asset(
                                  'assets/images/gifs/${workout.key}.gif')),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                futuraText(workout.key,
                                    textStyle: blackBoldStyle()),
                                futuraText(
                                    'Reps: ${workout.value['reps'].toString()}',
                                    textStyle: TextStyle(
                                        color: CustomColors.purpleSnail,
                                        fontWeight: FontWeight.bold)),
                                futuraText(
                                    'Sets: ${workout.value['sets'].toString()}',
                                    textStyle: TextStyle(
                                        color: CustomColors.purpleSnail,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            );
          }).toList(),
        );
      }).toList()),
    );
  }
}
