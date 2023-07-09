import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrescribeWorkoutScreen extends StatefulWidget {
  const PrescribeWorkoutScreen({Key? key}) : super(key: key);

  @override
  PrescribeWorkoutScreenState createState() => PrescribeWorkoutScreenState();
}

class PrescribeWorkoutScreenState extends State<PrescribeWorkoutScreen> {
  List<Map<dynamic, dynamic>> prescribedWorkouts = [];

  String selectedMuscle = '';
  String selectedExercise = '';
  int sets = 0;
  int reps = 0;

  List<String> muscleGroups = [
    "Abs",
    "Back",
    "Biceps",
    "Calves",
    "Chest",
    "Forearms",
    "Hamstrings",
    "Shoulders",
    "Trapezius",
    "Triceps"
  ];

  Map<String, List<String>> exercises = {};

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    String jsonFile = await rootBundle.loadString('lib/models/muscles.json');
    Map<String, dynamic> data = jsonDecode(jsonFile);
    data.forEach((key, value) {
      exercises[key] = List<String>.from(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescribe Workout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: muscleGroups[0],
              decoration:
                  const InputDecoration(labelText: 'Select Muscle Group'),
              items: muscleGroups.map((String muscle) {
                return DropdownMenuItem<String>(
                  value: muscle,
                  child: Text(muscle),
                );
              }).toList(),
              onChanged: (String? muscle) {
                setState(() {
                  if (muscle != null) {
                    selectedMuscle = muscle;
                  }

                  selectedExercise = '';
                });
              },
            ),
            if (selectedMuscle != '')
              DropdownButtonFormField<String>(
                value: selectedExercise,
                decoration: const InputDecoration(labelText: 'Select Exercise'),
                items: exercises[selectedMuscle]?.map((String exercise) {
                  return DropdownMenuItem<String>(
                    value: exercise,
                    child: Text(exercise),
                  );
                }).toList(),
                onChanged: (String? exercise) {
                  setState(() {
                    if (exercise != null) {
                      selectedExercise = exercise;
                    }
                  });
                },
              ),
            const SizedBox(height: 16),
            if (selectedExercise != '') ...[
              const Text('Sets'),
              Slider(
                value: sets.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (double value) {
                  setState(() {
                    sets = value.toInt();
                  });
                },
              ),
              const Text('Reps'),
              Slider(
                value: reps.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                onChanged: (double value) {
                  setState(() {
                    reps = value.toInt();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    prescribedWorkouts.add({
                      'muscle': selectedMuscle,
                      'exercise': selectedExercise,
                      'sets': sets,
                      'reps': reps,
                    });
                    selectedMuscle = '';
                    selectedExercise = '';
                    sets = 0;
                    reps = 0;
                  });
                },
                child: const Text('Add Workout'),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Prescribed Workouts'),
            Expanded(
              child: ListView.builder(
                itemCount: prescribedWorkouts.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> workout = prescribedWorkouts[index];
                  return Card(
                    child: ListTile(
                      title: Text(workout['muscle']),
                      subtitle: Text(workout['exercise']),
                      trailing: Text(
                          '${workout['sets']} sets, ${workout['reps']} reps'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      prescribedWorkouts.add({});
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 16),
                ...prescribedWorkouts
                    .map((workout) => buildWorkoutCard(workout))
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWorkoutCard(Map<dynamic, dynamic> workout) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Muscle Group'),
            DropdownButtonFormField<String>(
              value: workout['muscle'],
              onChanged: (String? value) {
                setState(() {
                  workout['muscle'] = value;
                });
              },
              items: muscleGroups.map((String muscle) {
                return DropdownMenuItem<String>(
                  value: muscle,
                  child: Text(muscle),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Exercise'),
            DropdownButtonFormField<String>(
              value: workout['exercise'],
              onChanged: (String? value) {
                setState(() {
                  workout['exercise'] = value;
                });
              },
              items: exercises[workout['muscle']]?.map((String exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(exercise),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Sets'),
            TextField(
              onChanged: (String value) {
                setState(() {
                  workout['sets'] = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Reps'),
            TextField(
              onChanged: (String value) {
                setState(() {
                  workout['reps'] = int.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
