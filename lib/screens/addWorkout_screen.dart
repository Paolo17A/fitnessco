// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _musclesController = TextEditingController();

  void _saveWorkout() async {
    // Store the workout data in Firebase Firestore
    String workoutName = _workoutNameController.text;
    String muscles = _musclesController.text;

    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('workouts')
          .get();
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> allWorkouts = [];
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data['allWorkouts'] != null) {
          if (data['allWorkouts'] is List) {
            allWorkouts = List<Map<String, dynamic>>.from(data['allWorkouts']);
          }
        }

// Check if workout name already exists
        if (allWorkouts.any((workout) =>
            workout['workout_name'].toString().toLowerCase() ==
            workoutName.toLowerCase())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout name already exists')),
          );
          return; // Exit the function if workout name exists
        }

        allWorkouts.add({
          'workout_name': workoutName,
          'muscles': muscles,
        });

        await docSnapshot.reference.update({
          'allWorkouts': allWorkouts,
        });

        // Show a snackbar to indicate successful saving of the workout
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout: $e')),
      );
    }
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _musclesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _workoutNameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _musclesController,
              decoration: const InputDecoration(
                labelText: 'Muscles',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
