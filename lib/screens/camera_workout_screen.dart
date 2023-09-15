import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/clientHome_screen.dart';
import 'package:flutter/services.dart';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/pose_detector_util.dart';
import '../utils/pose_painter_util.dart';

late List<CameraDescription> cameras;

class CameraWorkoutScreen extends StatefulWidget {
  const CameraWorkoutScreen({super.key});

  @override
  State<CameraWorkoutScreen> createState() => _CameraWorkoutScreenState();
}

class _CameraWorkoutScreenState extends State<CameraWorkoutScreen> {
  bool isLoading = true;

  //  ML Variables
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.back;

  //  Camera variables
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _changingCameraLens = false;

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
  bool mayAddRep = true;
  String _currentWorkoutInstruction = '';

  //  Accomplished Workout Variables
  List<dynamic> workoutHistory = [];
  Map<String, dynamic> accomplishedWorkouts = {};

  //declare detector
  @override
  void initState() {
    super.initState();
    _getClientWorkouts();
    _initialize();
  }

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    _stopLiveFeed();
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

  //  CAMERA FUNCTIONS
  //===============================================================================================
  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == _cameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    _processImage(inputImage);
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
        bytes: plane.bytes,
        inputImageData: InputImageData(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            imageRotation: rotation,
            inputImageFormat: format,
            planeData: [
              InputImagePlaneMetadata(bytesPerRow: plane.bytesPerRow)
            ]));
  }
  //===============================================================================================

  //  POSE ESTIMATION FUNCTIONS
  //===============================================================================================
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      switch (workouts[currentWorkoutIndex]) {
        //  AB WORKOUTS
        case 'Sit-ups':
          _currentWorkoutInstruction = mayAddRep
              ? 'Lie in the floor,  bend your knees so your feet are flat on the floor, to lift your back'
              : 'Lower your back to the starting position';
          break;
        case 'Squats':
          _currentWorkoutInstruction = mayAddRep
              ? 'Stand with your feet with hip-distance apart,  hips back and bend your knees'
              : 'Straighten your legs to return to a standing position';
          break;
        case 'Crunches':
          _currentWorkoutInstruction = mayAddRep
              ? 'Lie in the floor, bend your knees so your feet are flat on the floor, lift your chest '
              : 'Lower your back to the starting position';
          break;
        case 'Russian Twists':
          _currentWorkoutInstruction = mayAddRep
              ? 'Sit on the floor with your knees bent and feet flat on the floor'
              : 'Twist your torso to the right or to the left';
          break;
        // BICEP WORKOUTS
        case 'Left Arm Dumbell Curl':
          _currentWorkoutInstruction = mayAddRep
              ? 'Pull your left wrist upward'
              : 'Stretch out your left arm';
          break;
        case 'Right Arm Dumbell Curl':
          _currentWorkoutInstruction = mayAddRep
              ? 'Pull your right wrist upward'
              : 'Stretch out your right arm';
          break;
        case 'Barbell Curl':
          _currentWorkoutInstruction = mayAddRep
              ? 'Lift the barbell towards your chest'
              : 'Slowly lower the barbell as you stretch out your arms';
          break;
        //  BACK WORKOUTS
        case 'Deadlifts':
          _currentWorkoutInstruction = mayAddRep
              ? 'Slowly stand up as you lift the barbell upwards'
              : 'Bend your knees and hips slowly as you lower the barbell back to the floor';
          break;
        case 'Bent-Over Row':
          _currentWorkoutInstruction = mayAddRep
              ? 'Bend forward and pull your arms back and bend your elbows as you lift the barbell'
              : 'Outstretch your arms as lower the barbell back to the floor';
          break;
        //  LEG WORKOUTS
        case 'Lunges':
          _currentWorkoutInstruction = mayAddRep
              ? 'Step forward as you put one knee downward. Form a right angle with your knee'
              : 'Slowly return to a standing position';
          break;
        case 'Kettlebell Swings':
          _currentWorkoutInstruction = mayAddRep
              ? 'Swing the kettlbell upwards as you stand up straight'
              : 'Bring the kettlebell back down as you bend forward';
          break;
        //  CHEST WORKOUTS
        case 'Flat Barbell Bench Press':
          _currentWorkoutInstruction = mayAddRep
              ? 'Push the barbell upwards while lying flat on your back'
              : 'Slowly bring the barbell back down to chest level';
          break;
        case 'Inclined Dumbell Bench Press':
          _currentWorkoutInstruction = mayAddRep
              ? 'Push the dumbells upwards while lying inclined on your back'
              : 'Slowly bring the barbell back down to chest level';
          break;
        case 'Chest Pushups':
          _currentWorkoutInstruction = mayAddRep
              ? 'Begin in a plank position with your hands placed slightly wider than shoulder-width apart and push yourself upwards.'
              : 'Lower your chest towards the ground by bending your elbows, and maintaining your straight plank position';
          break;
        default:
          _currentWorkoutInstruction = mayAddRep
              ? 'Put your left hand above your nose (This workout has not been implemented yet)'
              : 'Put your left hand below your left hip (This workout has not been implemented yet)';
          break;
      }
    });
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

    switch (workouts[currentWorkoutIndex]) {
      case 'Sit-ups':
        for (var pose in poses) {
          if (mayAddRep && isFinishedSitUpPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingSitUpPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Crunches':
        for (var pose in poses) {
          if (mayAddRep && isFinishedCrunchPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingCrunchPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Squats':
        for (var pose in poses) {
          if (mayAddRep && isFinishedSquatPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStandingPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Russian Twists':
        for (var pose in poses) {
          if (mayAddRep && isFinishedRussianTwistPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingSitUpPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Left Arm Dumbell Curl':
        for (var pose in poses) {
          if (mayAddRep && (isFinishingLeftArmWristCurl(pose))) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && (isStartingLeftArmWristCurl(pose))) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Right Arm Dumbell Curl':
        for (var pose in poses) {
          if (mayAddRep && (isFinishingRightArmWristCurl(pose))) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && (isStartingRightArmWristCurl(pose))) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Barbell Curl':
        for (var pose in poses) {
          if (mayAddRep &&
              (isFinishingRightArmWristCurl(pose) &&
                  isFinishingLeftArmWristCurl(pose))) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep &&
              (isStartingRightArmWristCurl(pose) &&
                  isStartingLeftArmWristCurl(pose))) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Bent-Over Row':
        for (var pose in poses) {
          if (mayAddRep && isFinishedBentRowPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingBentRowPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Deadlifts':
        for (var pose in poses) {
          if (mayAddRep && isFinishedDeadliftPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingDeadliftPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Lunges':
        for (var pose in poses) {
          if (mayAddRep && isFinishingLungePosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingLungePosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Kettlebell Swings':
        for (var pose in poses) {
          if (mayAddRep && isFinishedKettlebellPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingKettlebellPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Flat Barbell Bench Press':
        for (var pose in poses) {
          if (mayAddRep && isFinishingFlatBarbellPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingFlatBarbellPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Inclined Dumbell Bench Press':
        for (var pose in poses) {
          if (mayAddRep && isFinishingInclinedDumbellPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingInclinedDumbellPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      case 'Chest Pushups':
        for (var pose in poses) {
          if (mayAddRep && isFinishingPushUpPosition(pose)) {
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isStartingPushUpPosition(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
      default:
        for (var pose in poses) {
          if (mayAddRep && isLeftHandAboveHead(pose)) {
            // Handle the case where the left hand is above the head
            mayAddRep = false;
            _addRepToCurrentSet();
          } else if (!mayAddRep && isLeftHandBelowHip(pose)) {
            setState(() {
              mayAddRep = true;
            });
          }
        }
        break;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  //===============================================================================================

  //WORKOUT RELATED FUNCTIONS
  //===============================================================================================
  void _addRepToCurrentSet() {
    setState(() {
      _currentRep++;
      _repsDone[_currentSet] = _currentRep;
      //mayAddRep = false;

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
                      setState(() {
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
                      });
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
        actions: [
          IconButton(
              onPressed: _switchLiveCamera,
              icon: const Icon(Icons.cameraswitch))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Align(alignment: Alignment.topCenter, child: _liveFeedBody()),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.black.withOpacity(0.75),
                    child: Center(
                        child: Text(
                      _currentWorkoutInstruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
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
                                  onPressed: () {
                                    mayAddRep = true;
                                    _addRepToCurrentSet();
                                  },
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

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      child: _changingCameraLens
          ? const Center(
              child: Text('Changing camera lens'),
            )
          : Padding(
              padding: const EdgeInsets.all(6.0),
              child: CameraPreview(
                _controller!,
                child: _customPaint,
              ),
            ),
    );
  }
}
