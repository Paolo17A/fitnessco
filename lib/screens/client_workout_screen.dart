import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/prescribe_workout_screen.dart';
import 'package:fitnessco/widgets/workout_card_widget.dart';
import 'package:flutter/material.dart';

class ClientWorkoutsScreen extends StatefulWidget {
  final String
      clientUID; //  we must pass it through here because we can access this screen via client or via trainer
  const ClientWorkoutsScreen({Key? key, required this.clientUID})
      : super(key: key);

  @override
  ClientWorkoutsScreenState createState() => ClientWorkoutsScreenState();
}

class ClientWorkoutsScreenState extends State<ClientWorkoutsScreen> {
  bool _isLoading = true;
  bool _isTrainer = false;
  Map<String, dynamic> prescribedWorkouts = {};

  @override
  void initState() {
    super.initState();
    _getPrescribedWorkout();
  }

  void _getPrescribedWorkout() async {
    try {
      final clientUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .get();

      prescribedWorkouts = clientUserData.data()!['prescribedWorkout'];
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
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<String> muscleKeys = prescribedWorkouts.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isTrainer ? "Client Workout" : "My Workout Plan"),
        actions: [
          if (_isTrainer)
            IconButton(
                onPressed: _goToPrescribeWorkoutScreen,
                icon: const Icon(Icons.add))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            _getPrescribedWorkout();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : prescribedWorkouts.isEmpty
                  ? const Center(
                      child: Text(
                      'No Prescribed Workouts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: ListView.builder(
                                itemCount: prescribedWorkouts.length,
                                itemBuilder: (context, index) {
                                  return WorkoutCardWidget(
                                    muscle: muscleKeys[index],
                                    workouts:
                                        prescribedWorkouts[muscleKeys[index]],
                                    viewedByTrainer: _isTrainer,
                                  );
                                })),
                      ],
                    ),
        ),
      ),
    );
  }
}
