import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _workoutHistory = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getWorkoutHistory();
  }

  void _getWorkoutHistory() async {
    final currentUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    _workoutHistory = currentUserData.data()!['workoutHistory'];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Workout History')),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                    child: _workoutHistory.isEmpty
                        ? const Text('YOu have no Workout History')
                        : Expanded(
                            child: ListView.builder(
                                itemCount: _workoutHistory.length,
                                itemBuilder: (context, index) {
                                  List<String> muscleGroups =
                                      (_workoutHistory[index]['workout']
                                              as Map<String, dynamic>)
                                          .keys
                                          .toList();
                                  return Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(9),
                                          child: Text(
                                            '${(_workoutHistory[index]['dateTime']['month']).toString()} - ${(_workoutHistory[index]['dateTime']['day']).toString()} - ${(_workoutHistory[index]['dateTime']['year']).toString()}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: Colors.white),
                                          ),
                                        ),
                                        Column(
                                          children:
                                              muscleGroups.map((muscleGroup) {
                                            List<String> workouts =
                                                (_workoutHistory[index]
                                                                ['workout']
                                                            [muscleGroup]
                                                        as Map<String, dynamic>)
                                                    .keys
                                                    .toList();
                                            return Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            muscleGroup
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                          children: workouts
                                                              .map((workout) {
                                                        List<dynamic> repsDone =
                                                            _workoutHistory[index]
                                                                        [
                                                                        'workout']
                                                                    [
                                                                    muscleGroup]
                                                                [
                                                                workout]['repsDone'];
                                                        int repsQuota = _workoutHistory[
                                                                        index]
                                                                    ['workout']
                                                                [muscleGroup][
                                                            workout]['repsQuota'];
                                                        return SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  workout,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child: Column(
                                                                    children:
                                                                        repsDone
                                                                            .map((reps) {
                                                                      return Text(
                                                                          'Set: $reps / $repsQuota',
                                                                          style:
                                                                              const TextStyle(color: Colors.white));
                                                                    }).toList(),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }).toList())
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ))));
  }
}
