import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/pose_painter_util.dart';

late List<CameraDescription> cameras;

class CameraWorkoutScreen extends StatefulWidget {
  const CameraWorkoutScreen({super.key});

  @override
  State<CameraWorkoutScreen> createState() => _CameraWorkoutScreenState();
}

class _CameraWorkoutScreenState extends State<CameraWorkoutScreen> {
  //  ML Variables
  dynamic cameraController;
  dynamic frontCameraController;
  dynamic poseDetector;

  bool isLoading = true;
  bool isBusy = false;
  late Size size;
  dynamic _scanResults;
  CameraImage? img;

  //  Current Workout Variables
  Map<String, dynamic> prescribedWorkouts = {};
  List<String> muscleGroups = [];
  int currentMuscleGroupIndex = 0;
  List<String> workouts = [];
  int currentWorkoutIndex = 0;
  int _currentRep = 0;
  int _repsQuota = 0;
  int _currentSet = 0;
  int _setQuota = 0;

  //declare detector
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getClientWorkouts();
    _initializeCamera();
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
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting client workouts: ${error.toString()}')));
      Navigator.pop(context);
    }
  }

  //initialize the camera feed
  _initializeCamera() async {
    try {
      //initialize detector
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      if (cameras.length > 1) {
        frontCameraController =
            CameraController(cameras[1], ResolutionPreset.high);
      }

      final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
      poseDetector = PoseDetector(options: options);

      await cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        (cameraController as CameraController).startImageStream((image) => {
              if (!isBusy)
                {isBusy = true, img = image, _doPoseEstimationOnFrame()}
            });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error Initializing Camera: ${error.toString()}')));
      Navigator.pop(context);
    }
    cameras = await availableCameras();
  }

  //close all resources
  @override
  void dispose() {
    if (mounted) {
      poseDetector.close();
      cameraController.dispose();
    }
    super.dispose();
  }

  //  POSE ESTIMATION FUNCTIONS
  //===============================================================================================
  _doPoseEstimationOnFrame() async {
    try {
      var inputImage = _getInputImage();
      final List<Pose> poses =
          await (poseDetector as PoseDetector).processImage(inputImage);
      _scanResults = poses;
      if (mounted) {
        setState(() {
          _scanResults;
          isBusy = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error estimating pose: ${error.toString()}')));
      Navigator.pop(context);
    }
  }

  InputImage _getInputImage() {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in img!.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final Size imageSize =
          Size(img!.width.toDouble(), img!.height.toDouble());
      final camera = cameras[0];
      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      // if (imageRotation == null) return;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(img!.format.raw);
      // if (inputImageFormat == null) return null;

      final planeData = img!.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation!,
        inputImageFormat: inputImageFormat!,
        planeData: planeData,
      );
      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

      return inputImage;
    } catch (e) {
      // Handle the error as needed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting input image: ${e.toString()}')));
      Navigator.pop(context);
      return InputImage.fromFilePath(
          ""); // Return a placeholder input image or handle the error case
    }
  }

  //===============================================================================================

  //WORKOUT RELATED FUNCTIONS
  //===============================================================================================
  void _addRepToCurrentSet() {
    _currentRep++;
    if (_currentRep == _repsQuota) {
      _currentSet++;
      _currentRep = 0;
      if (_currentSet == _setQuota) {
        //  Check if this is the last workout for this muscle group.
        if (currentWorkoutIndex + 1 == workouts.length) {
          currentWorkoutIndex = 0;
          //  Check if this is the final muscle group in the prescribed workout
          if (currentMuscleGroupIndex + 1 == muscleGroups.length) {
            _addWorkoutToFirebase();
          }
          //  If this isn't the last muscle group, simply proceed to the next muscle group in the prescribed workout
          else {
            currentMuscleGroupIndex++;
          }
        }
        //  If this isn't the last muscle workout, simply proceed to the next workout for this muscle
        else {
          currentWorkoutIndex++;
        }
      }
    }
    setState(() {
      _currentRep;
      _currentSet;
      currentWorkoutIndex;
      currentMuscleGroupIndex;
    });
  }

  void _skipWorkout() {
    if (currentWorkoutIndex + 1 == workouts.length) {
      if (currentMuscleGroupIndex + 1 == muscleGroups.length) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Confirm Skip Workout'),
                  content: const Text(
                      'Are you sure you want to skip this workout? This is the only workout you have been prescribed'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
        });
      }
    } else {
      setState(() {
        currentWorkoutIndex++;
        _currentRep = 0;
        _currentSet = 0;
      });
    }
  }

  void _skipMuscle() {
    if (currentMuscleGroupIndex + 1 == muscleGroups.length) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Confirm Skip Workout'),
                content: const Text(
                    'Are you sure you want to skip this muscle? This is the only muscle you have been prescribed to train'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
      });
    }
  }

  void _addWorkoutToFirebase() {
    setState(() {
      isLoading = true;
    });
  }
  //===============================================================================================

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pose Estimation",
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      if (cameraController != null)
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          width: size.width,
                          height: size.height,
                          child: Container(
                            child: (cameraController.value.isInitialized)
                                ? AspectRatio(
                                    aspectRatio:
                                        cameraController.value.aspectRatio,
                                    child: CameraPreview(cameraController),
                                  )
                                : const Center(
                                    child: Text('Camera not working'),
                                  ),
                          ),
                        ),
                      if (cameraController != null)
                        Positioned(
                            top: 0.0,
                            left: 0.0,
                            width: size.width,
                            height: size.height,
                            child: buildResult())
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.6),
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
                                  onPressed: _skipMuscle,
                                  child: const Text('Skip Muscle'))
                            ],
                          ),
                        )
                      ],
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

  //Show rectangles around detected objects
  Widget buildResult() {
    if (_scanResults == null ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      return const Text('');
    }

    final Size imageSize = Size(
      cameraController.value.previewSize!.height,
      cameraController.value.previewSize!.width,
    );
    CustomPainter painter = PosePainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }
}
