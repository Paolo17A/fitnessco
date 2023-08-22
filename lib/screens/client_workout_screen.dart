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
  Map<String, dynamic> appointment = {};

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
      appointment = clientUserData.data()!['appointment'];

      //Check if the date is surpassed
      if (appointment.isNotEmpty) {
        DateTime oldAppointment = DateTime(
            appointment['year'],
            appointment['month'],
            appointment['day'],
            appointment['hour'],
            appointment['minute']);

        if (oldAppointment.isBefore(DateTime.now())) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.clientUID)
              .update({'appointment': {}});
          appointment = {};
        }
      }

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

  void _deleteWorkout(String muscle, String workout) async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> selectedMuscle = prescribedWorkouts[muscle];
      if (selectedMuscle.length == 1) {
        prescribedWorkouts.remove(muscle);
      } else {
        selectedMuscle.remove(workout);
        prescribedWorkouts[muscle] = selectedMuscle;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .update({'prescribedWorkout': prescribedWorkouts});

      _getPrescribedWorkout();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting workout: ${error.toString()}')));
    }
  }

  String _formatTwoDigits(int n) {
    return n.toString().padLeft(2, '0');
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
              : Column(
                  children: [
                    if (prescribedWorkouts.isNotEmpty)
                      appointment.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No Scheduled Training',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                  'Next Workout: ${_formatTwoDigits(appointment['year'])}-${_formatTwoDigits(appointment['month'])}-${_formatTwoDigits(appointment['day'])} ${_formatTwoDigits((appointment['hour'] as int) % 12)}:${_formatTwoDigits(appointment['minute'])} ${(appointment['hour'] as int) >= 12 ? 'PM' : 'AM'} ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple)),
                            ),
                    prescribedWorkouts.isEmpty
                        ? const Center(
                            child: Text(
                            'No Prescribed Workouts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple),
                          ))
                        : Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: prescribedWorkouts.length,
                                itemBuilder: (context, index) {
                                  return WorkoutCardWidget(
                                    muscle: muscleKeys[index],
                                    workouts:
                                        prescribedWorkouts[muscleKeys[index]],
                                    viewedByTrainer: _isTrainer,
                                    onDeleteCallback: _deleteWorkout,
                                  );
                                })),
                  ],
                ),
        ),
      ),
    );
  }
}
