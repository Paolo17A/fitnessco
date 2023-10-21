import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/navigation_bar_widgets.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _workoutHistory = [];
  String _firstName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getWorkoutHistory();
  }

  void _getWorkoutHistory() async {
    final currentUserData = await getCurrentUserData();

    _firstName = currentUserData['firstName'];
    _workoutHistory = currentUserData['workoutHistory'];
    _workoutHistory = List.from(_workoutHistory.reversed);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _workoutHistoryAppBar(),
        bottomNavigationBar: clientNavBar(context, currentIndex: 2),
        body: switchedLoadingContainer(
            _isLoading,
            userAuthBackgroundContainer(context,
                child: _workoutHistoryContainer())));
  }

  AppBar _workoutHistoryAppBar() {
    return AppBar(
        title: Center(
            child: futuraText('WORKOUT HISTORY', textStyle: blackBoldStyle())),
        automaticallyImplyLeading: false);
  }

  Widget _workoutHistoryContainer() {
    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: SafeArea(
                child: _workoutHistory.isEmpty
                    ? Center(child: futuraText('You have no Workout History'))
                    : _workoutEntries())),
      ],
    );
  }

  Widget _workoutEntries() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _workoutHistory.length,
        itemBuilder: (context, index) {
          final currentWorkoutHistory = _workoutHistory[index];
          final workoutMuscles = currentWorkoutHistory['workout'];
          final dateTime = currentWorkoutHistory['dateTime'];
          String formattedTime =
              '${dateTime['month']} - ${dateTime['day']} - ${dateTime['year']}';
          return _workoutHistoryEntry(
              formattedTime: formattedTime,
              workoutMuscles: workoutMuscles,
              isFirst: index == 0);
        });
  }

  Widget _workoutHistoryEntry(
      {required String formattedTime,
      required Map<dynamic, dynamic> workoutMuscles,
      required bool isFirst}) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            height: isFirst ? 350 : 250,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  CustomColors.electricLavender,
                  CustomColors.rosePink
                ]),
                borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              child: Column(children: [
                if (isFirst)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(children: [
                        futuraText('Hi, $_firstName',
                            textStyle: whiteBoldStyle(size: 32)),
                        Divider(color: Colors.grey, thickness: 1),
                        futuraText('This is what you\'ve achieved so far',
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 15)),
                        Divider(color: Colors.grey, thickness: 1)
                      ])),
                //TIME
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: futuraText(formattedTime,
                        textStyle: blackBoldStyle(size: 30))),
                //WORKOUT
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: workoutMuscles.keys.map((muscleGroup) {
                            final currentMuscleGroup =
                                (workoutMuscles[muscleGroup]
                                    as Map<String, dynamic>);
                            final workouts = currentMuscleGroup.keys.toList();
                            return Column(
                                children: workouts
                                    .map((workout) => futuraText(workout,
                                        textStyle: blackBoldStyle(size: 18)))
                                    .toList());
                          }).toList()),
                    ]))
              ]),
            )));
  }
}
