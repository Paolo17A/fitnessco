import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrescribeWorkoutScreen extends StatefulWidget {
  final String clientUID;
  const PrescribeWorkoutScreen({super.key, required this.clientUID});

  @override
  State<PrescribeWorkoutScreen> createState() => _PrescribeWorkoutScreenState();
}

class _PrescribeWorkoutScreenState extends State<PrescribeWorkoutScreen> {
  bool _isLoading = true;
  Map<String, List<String>> exercises = {};

  String? selectedMuscleGroup;
  String? selectedWorkout;

  //  These values will ve filled up as we go
  List<String> allMuscles = [];
  List<String> selectableWorkouts = [];
  final setsInputController = TextEditingController();
  final repsInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  @override
  void dispose() {
    super.dispose();
    setsInputController.dispose();
    repsInputController.dispose();
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
    if (selectedMuscleGroup == null ||
        selectedWorkout == null ||
        repsInputController.text.isEmpty ||
        setsInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill up all fields')));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final getUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .get();
      Map<dynamic, dynamic> prescribedWorkout =
          getUserData.data()!['prescribedWorkout'];
      //  This is the first workout to be added by the trainer
      if (prescribedWorkout.isEmpty) {
        prescribedWorkout = {
          selectedMuscleGroup!: {
            selectedWorkout: {
              'reps': int.parse(repsInputController.text),
              'sets': int.parse(setsInputController.text)
            }
          }
        };
      }
      //  The trainer is prescribing an nth workout from an existing muscle in the workout prescription
      else if (!prescribedWorkout.containsKey(selectedMuscleGroup)) {
        prescribedWorkout[selectedMuscleGroup] = {
          selectedWorkout: {
            'reps': int.parse(repsInputController.text),
            'sets': int.parse(setsInputController.text)
          }
        };
      }
      //  The Trainer is updating an already existing workout
      else {
        prescribedWorkout[selectedMuscleGroup][selectedWorkout] = {
          'reps': int.parse(repsInputController.text),
          'sets': int.parse(setsInputController.text)
        };
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .update({'prescribedWorkout': prescribedWorkout});

      navigatorState.pop();
      navigatorState.pushReplacement(MaterialPageRoute(
          builder: (context) =>
              ClientWorkoutsScreen(clientUID: widget.clientUID)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding workout: ${error.toString()}')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Center(
              child: Container(
                color: Colors.purple.withOpacity(0.75),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Select a muscle group:',
                              style: _textStyleWhite(),
                            ),
                            DropdownButton<String>(
                              value: selectedMuscleGroup,
                              dropdownColor: Colors.purple,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedMuscleGroup = newValue!;
                                  selectedWorkout = null;
                                  selectableWorkouts =
                                      exercises[selectedMuscleGroup]!;
                                });
                              },
                              items: allMuscles.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select a Workout:',
                              style: _textStyleWhite(),
                            ),
                            DropdownButton<String>(
                              value: selectedWorkout,
                              dropdownColor: Colors.purple,
                              onChanged: selectedMuscleGroup == null
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        selectedWorkout = newValue!;
                                      });
                                    },
                              items: selectableWorkouts
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Input number of Sets:',
                              style: _textStyleWhite(),
                            ),
                            _numericalInputField(setsInputController),
                            Text(
                              'Input number of Reps:',
                              style: _textStyleWhite(),
                            ),
                            _numericalInputField(repsInputController),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _addWorkout,
                          child: const Text('ADD WORKOUT'))
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyleWhite() {
    return const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  }

  Widget _numericalInputField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.purple.withOpacity(0.5)),
        width: 100,
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
