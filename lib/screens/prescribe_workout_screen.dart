import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/fitnessco_textfield_widget.dart';

class PrescribeWorkoutScreen extends StatefulWidget {
  final String clientUID;
  final DateTime dateTime;
  final Map<dynamic, dynamic> currentWorkouts;
  final String workoutID;
  final bool viewingSchedule;
  final String description;
  PrescribeWorkoutScreen(
      {super.key,
      required this.clientUID,
      required this.dateTime,
      required this.currentWorkouts,
      required this.viewingSchedule,
      required this.description,
      this.workoutID = ''});

  @override
  State<PrescribeWorkoutScreen> createState() => _PrescribeWorkoutScreenState();
}

class _PrescribeWorkoutScreenState extends State<PrescribeWorkoutScreen> {
  bool _isLoading = true;
  Map<String, List<String>> exercises = {};

  //  These values will ve filled up as we go
  List<String> allMuscles = [];
  Map<dynamic, dynamic> currentWorkoutSelection = {};
  final workoutDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentWorkoutSelection = widget.currentWorkouts;
    loadExercises();
    workoutDescriptionController.text = widget.description;
  }

  @override
  void dispose() {
    super.dispose();
    workoutDescriptionController.dispose();
  }

  Future<void> loadExercises() async {
    String jsonFile = await rootBundle.loadString('lib/data/muscles.json');
    Map<String, dynamic> data = jsonDecode(jsonFile);
    data.forEach((key, value) {
      exercises[key] = List<String>.from(value);
    });

    setState(() {
      allMuscles = exercises.keys.toList();
      _isLoading = false;
    });
  }

  void _addWorkout() async {
    final navigatorState = Navigator.of(context);
    if (workoutDescriptionController.text.isEmpty) {
      showErrorMessage(context, label: 'Please provide a workout title.');
      return;
    }
    if (currentWorkoutSelection.isEmpty) {
      showErrorMessage(context,
          label: 'You have not yet selected any workouts.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final getUserData = await getThisUserData(widget.clientUID);
      Map<dynamic, dynamic> prescribedWorkouts =
          getUserData.data()!['prescribedWorkouts'];
      if (widget.workoutID.isNotEmpty) {
        prescribedWorkouts[widget.workoutID] = {
          'workout': currentWorkoutSelection,
          'description': workoutDescriptionController.text.trim(),
          'workoutDate': widget.dateTime
        };
      } else {
        print('ADDING NEW ENTRY');
        String workoutID = DateTime.now().millisecondsSinceEpoch.toString();
        prescribedWorkouts[workoutID] = {
          'workout': currentWorkoutSelection,
          'description': workoutDescriptionController.text.trim(),
          'workoutDate': widget.dateTime
        };
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .update({'prescribedWorkouts': prescribedWorkouts});

      navigatorState.pop();
      if (widget.viewingSchedule) {
        navigatorState.pushReplacementNamed('/trainerSchedule');
      } else {
        navigatorState.pushReplacement(MaterialPageRoute(
            builder: (context) =>
                ClientWorkoutsScreen(clientUID: widget.clientUID)));
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context,
          label: 'Error adding workout: ${error.toString()}');
    }
  }

  bool _muscleIsInWorkoutSelection(String muscle) {
    return currentWorkoutSelection.containsKey(muscle);
  }

  bool _workoutIsInWorkoutSelection(String muscle, String workout) {
    return _muscleIsInWorkoutSelection(muscle) &&
        currentWorkoutSelection[muscle]!.containsKey(workout);
  }

  void addMuscleToWorkoutSelection(String muscle) {
    currentWorkoutSelection[muscle] = {};
  }

  void addWorkoutToWorkoutSelection(String muscle, String workout) {
    currentWorkoutSelection[muscle]![workout] = {'reps': 1, 'sets': 1};
  }

  void removeWorkoutFromMuscle(String muscle, String workout) {
    currentWorkoutSelection[muscle]!.remove(workout);
    if (currentWorkoutSelection[muscle]!.isEmpty) {
      currentWorkoutSelection.remove(muscle);
    }
  }

  int getWorkoutReps(String muscle, String workout) {
    return currentWorkoutSelection[muscle]![workout]['reps'];
  }

  int getWorkoutSets(String muscle, String workout) {
    return currentWorkoutSelection[muscle]![workout]['sets'];
  }

  void addRepToWorkout(String muscle, String workout) {
    if (getWorkoutReps(muscle, workout) == 12) {
      return;
    }
    setState(() {
      currentWorkoutSelection[muscle]![workout]['reps'] =
          getWorkoutReps(muscle, workout) + 1;
    });
  }

  void addSetToWorkout(String muscle, String workout) {
    if (getWorkoutSets(muscle, workout) == 4) {
      return;
    }
    setState(() {
      currentWorkoutSelection[muscle]![workout]['sets'] =
          getWorkoutSets(muscle, workout) + 1;
    });
  }

  void subtractRepFromWorkout(String muscle, String workout) {
    if (getWorkoutReps(muscle, workout) == 1) {
      return;
    }
    setState(() {
      currentWorkoutSelection[muscle]![workout]['reps'] =
          getWorkoutReps(muscle, workout) - 1;
    });
  }

  void subtractSetFromWorkout(String muscle, String workout) {
    if (getWorkoutSets(muscle, workout) == 1) {
      return;
    }
    setState(() {
      currentWorkoutSelection[muscle]![workout]['sets'] =
          getWorkoutSets(muscle, workout) - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
            child: Column(
          children: [
            futuraText('ADD WORKOUT', textStyle: whiteBoldStyle(size: 26)),
          ],
        )),
      ),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: stackedLoadingContainer(context, _isLoading, [
            workoutPlanBackgroundContainer(
              context,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _workoutDescription(),
                      _musclesCarousel(),
                      gradientOvalButton(
                          label: 'ADD WORKOUT', width: 200, onTap: _addWorkout)
                    ],
                  ),
                ),
              ),
            )
          ])),
    );
  }

  Widget _workoutDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(children: [
            futuraText(DateFormat('dd MMM yyyy').format(widget.dateTime),
                textStyle: blackBoldStyle())
          ]),
          Padding(
            padding: const EdgeInsets.all(10),
            child: fitnesscoTextField('WORKOUT DESCRIPTION', TextInputType.text,
                workoutDescriptionController,
                typeColor: Colors.black),
          ),
          futuraText('Select workouts to prescribe below.')
        ],
      ),
    );
  }

  Widget _musclesCarousel() {
    return CarouselSlider.builder(
        itemCount: allMuscles.length,
        itemBuilder: ((context, index, _) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child:
                    futuraText(allMuscles[index], textStyle: blackBoldStyle()),
              ),
              _availableWorkouts(
                  allMuscles[index], exercises[allMuscles[index]]!)
            ]),
          );
        }),
        options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.55,
            viewportFraction: 1,
            enableInfiniteScroll: false));
  }

  Widget _availableWorkouts(String muscle, List<String> workouts) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: SingleChildScrollView(
        child: Column(
            children: workouts.map((exercise) {
          return _workoutTile(muscle, exercise);
        }).toList()),
      ),
    );
  }

  Widget _workoutTile(String muscle, String exercise) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        height: 120,
        color: CustomColors.love,
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Container(
                    height: 75,
                    width: 75,
                    color: Colors.white,
                    child: Image.asset('assets/images/gifs/${exercise}.gif')),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    children: [
                      futuraText(exercise),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          removeButton(onPress: () {
                            if (_workoutIsInWorkoutSelection(
                                muscle, exercise)) {
                              subtractRepFromWorkout(muscle, exercise);
                            }
                          }),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: futuraText(
                                '${_workoutIsInWorkoutSelection(muscle, exercise) ? getWorkoutReps(muscle, exercise).toString() : '0'} Reps'),
                          ),
                          addButton(onPress: () {
                            if (_workoutIsInWorkoutSelection(
                                muscle, exercise)) {
                              addRepToWorkout(muscle, exercise);
                            }
                          })
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          removeButton(onPress: () {
                            if (_workoutIsInWorkoutSelection(
                                muscle, exercise)) {
                              subtractSetFromWorkout(muscle, exercise);
                            }
                          }),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: futuraText(
                                '${_workoutIsInWorkoutSelection(muscle, exercise) ? getWorkoutSets(muscle, exercise).toString() : '0'} Sets'),
                          ),
                          addButton(onPress: () {
                            if (_workoutIsInWorkoutSelection(
                                muscle, exercise)) {
                              addSetToWorkout(muscle, exercise);
                            }
                          })
                        ],
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Transform.scale(
                    scale: 2,
                    child: Checkbox(
                        value: _workoutIsInWorkoutSelection(muscle, exercise),
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                        side: BorderSide.none,
                        splashRadius: 10,
                        shape: CircleBorder(),
                        onChanged: (newVal) {
                          if (newVal == null) {
                            return;
                          }
                          setState(() {
                            //  We are ADDING
                            if (newVal) {
                              if (!_muscleIsInWorkoutSelection(muscle)) {
                                addMuscleToWorkoutSelection(muscle);
                              }
                              addWorkoutToWorkoutSelection(muscle, exercise);
                            }
                            // We are REMOVING
                            else {
                              removeWorkoutFromMuscle(muscle, exercise);
                            }
                          });
                        }),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget removeButton({required Function onPress}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton.outlined(
          splashColor: Colors.black,
          onPressed: () => onPress(),
          color: Colors.pink,
          icon: Icon(Icons.remove)),
    );
  }

  Widget addButton({required Function onPress}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton.outlined(
          splashColor: Colors.black,
          onPressed: () => onPress(),
          color: Colors.pink,
          icon: Icon(Icons.add)),
    );
  }
}
