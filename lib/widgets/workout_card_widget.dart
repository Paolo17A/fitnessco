import 'package:flutter/material.dart';

class WorkoutCardWidget extends StatefulWidget {
  final String muscle;
  final Map<String, dynamic> workouts;
  final bool viewedByTrainer;
  final void Function(String, String) onDeleteCallback;
  const WorkoutCardWidget(
      {super.key,
      required this.muscle,
      required this.workouts,
      required this.viewedByTrainer,
      required this.onDeleteCallback});

  @override
  State<WorkoutCardWidget> createState() => _WorkoutCardWidgetState();
}

class _WorkoutCardWidgetState extends State<WorkoutCardWidget> {
  String? selectedMuscleGroup;
  String? selectedWorkout;
  int? sets;
  int? reps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.6),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(11),
              child: Text(
                widget.muscle.toUpperCase(),
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.workouts.length,
                  itemBuilder: (context, index) {
                    List<String> workoutNames = widget.workouts.keys.toList();
                    return Padding(
                      padding: const EdgeInsets.all(6),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.6),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: Text(workoutNames[index],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Sets: ${widget.workouts[workoutNames[index]]['sets']}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Reps: ${widget.workouts[workoutNames[index]]['reps']}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (widget.viewedByTrainer)
                                  IconButton(
                                      onPressed: () {
                                        widget.onDeleteCallback(
                                            widget.muscle, workoutNames[index]);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ))
                              ],
                            ),
                          )),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
