import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/clientHome_screen.dart';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/pose_painter_util.dart';
import '../view/camera_view.dart';

late List<CameraDescription> cameras;

class CameraWorkoutScreen extends StatefulWidget {
  const CameraWorkoutScreen({super.key});

  @override
  State<CameraWorkoutScreen> createState() => _CameraWorkoutScreenState();
}

class _CameraWorkoutScreenState extends State<CameraWorkoutScreen> {
  //  ML Variables
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.back;

  bool mayAddRep = true;

  //  Detector Variables

  bool isLoading = true;

  //  Current Workout Variables
  Map<String, dynamic> prescribedWorkouts = {};
  List<String> muscleGroups = [];
  int currentMuscleGroupIndex = 0;
  List<String> workouts = [];
  int currentWorkoutIndex = 0;
  List<int> _repsDone = [];
  int _currentRep = 0;
  int _repsQuota = 0;
  int _currentSet = 0;
  int _setQuota = 0;

  //  Accomplished Workout Variables
  List<dynamic> workoutHistory = [];
  Map<String, dynamic> accomplishedWorkouts = {};

  //declare detector
  @override
  void initState() {
    super.initState();
    _getClientWorkouts();
  }

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _getClientWorkouts() async {
    try {
      final currentUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      prescribedWorkouts = currentUserData.data()!['prescribedWorkout'];
      muscleGroups = prescribedWorkouts.keys.toList();
      workouts = (prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
              as Map<String, dynamic>)
          .keys
          .toList();
      _repsQuota = prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
          [workouts[currentWorkoutIndex]]['reps'];
      _setQuota = prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
          [workouts[currentWorkoutIndex]]['sets'];
      _repsDone = List<int>.filled(_setQuota, 0);
      workoutHistory = currentUserData.data()!['workoutHistory'];
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting client workouts: ${error.toString()}')));
      Navigator.pop(context);
    }
  }

  //  POSE ESTIMATION FUNCTIONS
  //===============================================================================================
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    final poses = await _poseDetector.processImage(inputImage);

    if (inputImage.inputImageData == null) {
      _customPaint = null;
      return;
    }
    final painter = PosePainter(
      poses,
      inputImage.inputImageData!.size,
      inputImage.inputImageData!.imageRotation,
      _cameraLensDirection,
    );
    _customPaint = CustomPaint(painter: painter);

    for (var pose in poses) {
      if (_isLeftHandAboveHead(pose) && mayAddRep) {
        // Handle the case where the left hand is above the head
        mayAddRep = false;
        _addRepToCurrentSet();
      }
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  bool _isLeftHandAboveHead(Pose pose) {
    // Assuming landmarks are stored in PoseLandmarkType enum
    PoseLandmark? leftHand = pose.landmarks[PoseLandmarkType.leftWrist];
    PoseLandmark? head = pose.landmarks[PoseLandmarkType.nose];

    if (leftHand != null && head != null) {
      double leftHandToHeadDistance = leftHand.y - head.y;

      // Define a threshold distance to determine if the hand is above the head
      double aboveHeadThreshold = -0.1; // Adjust this value as needed

      return leftHandToHeadDistance < aboveHeadThreshold;
    }

    return false;
  }

  bool isRightHandAboveHead(Pose pose) {
    // Assuming landmarks are stored in PoseLandmarkType enum
    PoseLandmark? rightHand = pose.landmarks[PoseLandmarkType.rightWrist];
    PoseLandmark? head = pose.landmarks[PoseLandmarkType.nose];

    if (rightHand != null && head != null) {
      double rightHandToHeadDistance = rightHand.y - head.y;

      // Define a threshold distance to determine if the hand is above the head
      double aboveHeadThreshold = -0.1; // Adjust this value as needed

      return rightHandToHeadDistance < aboveHeadThreshold;
    }

    return false;
  }
  //===============================================================================================

  //WORKOUT RELATED FUNCTIONS
  //===============================================================================================
  void _addRepToCurrentSet() {
    setState(() {
      _currentRep++;
      _repsDone[_currentSet] = _currentRep;

      //  This is the first rep for this specific muscle group, hence also the first workout of this muscle group
      if (!accomplishedWorkouts
          .containsKey(muscleGroups[currentMuscleGroupIndex])) {
        accomplishedWorkouts[muscleGroups[currentMuscleGroupIndex]] = {
          workouts[currentWorkoutIndex]: {
            'repsQuota': _repsQuota,
            'repsDone': _repsDone
          }
        };
      }
      //  The current muscle group already exists but the current workout does not
      else if (!(accomplishedWorkouts[muscleGroups[currentMuscleGroupIndex]]
              as Map<dynamic, dynamic>)
          .containsKey(workouts[currentWorkoutIndex])) {
        accomplishedWorkouts[muscleGroups[currentMuscleGroupIndex]]
            [workouts[currentWorkoutIndex]] = {
          'repsQuota': _repsQuota,
          'repsDone': _repsDone
        };
      }
      //  This is the nth rep to be updated to an existing muscle group and workout group
      else {
        accomplishedWorkouts[muscleGroups[currentMuscleGroupIndex]]
            [workouts[currentWorkoutIndex]]['repsDone'] = _repsDone;
      }

      //  User has met the reps quota for the current sets
      if (_currentRep == _repsQuota) {
        _currentSet++;
        _currentRep = 0;

        //  User has met the sets quota for the current workout
        if (_currentSet == _setQuota) {
          _currentSet = 0;
          currentWorkoutIndex++;

          //  User has done all the workouts for the given muscle group
          if (currentWorkoutIndex == workouts.length) {
            currentWorkoutIndex = 0;
            currentMuscleGroupIndex++;

            //  User has trained all the muscles in the prescribed workout plan
            if (currentMuscleGroupIndex == muscleGroups.length) {
              _addWorkoutToFirebase();
            } else {
              workouts =
                  (prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
                          as Map<String, dynamic>)
                      .keys
                      .toList();
              _resetWorkoutVariables();
            }
          } else {
            _resetWorkoutVariables();
          }
        }
      }
    });
  }

  void _resetWorkoutVariables() {
    _repsQuota = prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
        [workouts[currentWorkoutIndex]]['reps'];
    _setQuota = prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
        [workouts[currentWorkoutIndex]]['sets'];
    _repsDone = List<int>.filled(_setQuota, 0);
  }

  void _skipWorkout() {
    //  If there is only one workout, we display a confirmation pop-up dialogue
    if (workouts.length == 1) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Confirm Skip Workout'),
                content: const Text(
                    'Are you sure you want to skip this workout? This is the only workout prescribed for this muscle'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentMuscleGroupIndex++;
                        currentWorkoutIndex = 0;
                        _currentRep = 0;
                        _currentSet = 0;
                        //  This is either the last or the only muscle to be trained
                        if (currentMuscleGroupIndex == muscleGroups.length) {
                          _addWorkoutToFirebase();
                        }
                        //  Move on to the next muscle
                        else {
                          workouts = (prescribedWorkouts[
                                      muscleGroups[currentMuscleGroupIndex]]
                                  as Map<String, dynamic>)
                              .keys
                              .toList();
                          _resetWorkoutVariables();
                        }
                      });
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ));
      return;
    }
    //  There are multiple prescribed workouts for this muscle group
    else {
      setState(() {
        currentWorkoutIndex++;
        _currentRep = 0;
        _currentSet = 0;
        //  This is the last workout for this muscle group
        if (currentWorkoutIndex == workouts.length) {
          currentMuscleGroupIndex++;
          currentWorkoutIndex = 0;
          //  If this is the final muscle group, time to updated the workout history in Firebase
          if (currentMuscleGroupIndex == muscleGroups.length) {
            _addWorkoutToFirebase();
          }
          //  Load the next workout of the same muscle group and set the proper related variables
          else {
            workouts =
                (prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
                        as Map<String, dynamic>)
                    .keys
                    .toList();
            _resetWorkoutVariables();
          }
        }
        //  We proceed to the next prescribed workout for this muscle group
        else {
          _resetWorkoutVariables();
        }
      });
    }
  }

  void _skipMuscle() {
    if (!accomplishedWorkouts
        .containsKey(muscleGroups[currentMuscleGroupIndex])) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Confirm Skip Workout'),
                content: const Text(
                    'Are you sure you want to skip this muscle? You have not trained this muscle yet'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      currentMuscleGroupIndex++;
                      currentWorkoutIndex = 0;
                      _currentRep = 0;
                      _currentSet = 0;
                      if (currentMuscleGroupIndex == muscleGroups.length) {
                        _addWorkoutToFirebase();
                      } else {
                        workouts = (prescribedWorkouts[
                                    muscleGroups[currentMuscleGroupIndex]]
                                as Map<String, dynamic>)
                            .keys
                            .toList();
                        _resetWorkoutVariables();
                      }
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ));
    } else {
      setState(() {
        currentMuscleGroupIndex++;
        currentWorkoutIndex = 0;
        _currentRep = 0;
        _currentSet = 0;
        //  Proceed to updating workouts in Firebase if all muscles have been elapsed
        if (currentMuscleGroupIndex == muscleGroups.length) {
          _addWorkoutToFirebase();
        }
        //  Reset workout variables to make way for the next workout
        else {
          workouts = (prescribedWorkouts[muscleGroups[currentMuscleGroupIndex]]
                  as Map<String, dynamic>)
              .keys
              .toList();
          _resetWorkoutVariables();
        }
      });
    }
  }

  void _addWorkoutToFirebase() async {
    setState(() {
      isLoading = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      //  Make a checker for if the  user did not do any workouts at all
      if (accomplishedWorkouts.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text(
                'You skipped all your workouts. No history will be recorded')));

        navigator.pop();
        navigator.pushReplacement(MaterialPageRoute(
            builder: ((context) => const ClientHomeScreen())));
      }
      //  There is SOMETHING in the accomplishedWorkouts map
      else {
        Map<dynamic, dynamic> newWorkoutEntry = {
          'dateTime': {
            'month': DateTime.now().month,
            'year': DateTime.now().year,
            'day': DateTime.now().day
          },
          'workout': accomplishedWorkouts
        };
        workoutHistory.add(newWorkoutEntry);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'workoutHistory': workoutHistory});

        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Successfully updated Workout History')));

        navigator.pop();
        navigator.pushReplacement(MaterialPageRoute(
            builder: ((context) => const ClientHomeScreen())));
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error adding workout history: ${error.toString()}')));
    }
  }
  //===============================================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pose Estimation",
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Align(
                    alignment: Alignment.topCenter,
                    child: CameraView(
                      customPaint: _customPaint,
                      onImage: _processImage,
                      initialCameraLensDirection: _cameraLensDirection,
                      onCameraLensDirectionChanged: (value) =>
                          _cameraLensDirection = value,
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                              'Current Muscle Group: ${muscleGroups[currentMuscleGroupIndex]}',
                              style: _textStyle()),
                          const SizedBox(height: 10),
                          Text(
                              'Current Workout: ${workouts[currentWorkoutIndex]}',
                              style: _textStyle()),
                          const SizedBox(height: 10),
                          Text('Current Set: $_currentSet / $_setQuota',
                              style: _textStyle()),
                          const SizedBox(height: 10),
                          Text('Reps Done: $_currentRep / $_repsQuota',
                              style: _textStyle()),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: _skipWorkout,
                                    child: const Text('Skip Workout')),
                                FloatingActionButton(
                                  onPressed: _addRepToCurrentSet,
                                  child: const Icon(Icons.add),
                                ),
                                ElevatedButton(
                                    onPressed: muscleGroups.length == 1
                                        ? null
                                        : _skipMuscle,
                                    child: const Text('Skip Muscle'))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
  }
}
