import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WarmUpScreen extends StatefulWidget {
  const WarmUpScreen({super.key});

  @override
  State<WarmUpScreen> createState() => _WarmUpScreenState();
}

enum WarmUpStates {
  START,
  STAY_AWAY,
  JOG,
  JOG_COUNTDOWN,
  JOG_DURATION,
  JOG_DONE,
  FIRST_REST,
  JUMPING_JACK,
  JUMPING_JACK_COUNTDOWN,
  JUMPING_JACK_DURATION,
  JUMPING_JACK_DONE,
  SECOND_REST,
  HIP_CIRCLES,
  HIP_CIRCLES_COUNTDOWN,
  HIP_CIRCLES_DURATION,
  HIP_CIRCLES_DONE,
  LAST_REST,
  FINAL_REMINDER
}

class _WarmUpScreenState extends State<WarmUpScreen> {
  WarmUpStates _currentWarmUpState = WarmUpStates.START;
  FlutterTts flutterTts = FlutterTts();
  String spokenMessage = 'Hi. Let\'s begin with some whole body warmups.';
  String additionalExplanation = '';
  String imageAssetPath = 'assets/images/warmups/warmup_start.png';
  bool _isDoneWarmingUp = false;

  //  TIMER
  int _secondsRemaining = 30;
  Timer _timer = Timer(Duration(seconds: 3), () {});

  AudioPlayer audioPlayer = AudioPlayer();

  //  CURRENT WARMUP STATE GETTERS AND SETTERS
  //============================================================================
  WarmUpStates get GetCurrentWarmUpState {
    return _currentWarmUpState;
  }

  void SetCurrentWarmUpState(WarmUpStates _state) {
    additionalExplanation = '';
    switch (_state) {
      case WarmUpStates.START:
        spokenMessage = 'Hi. Let us begin with some whole body warm ups.';
        imageAssetPath = 'assets/images/warmups/warmup_start.png';
        break;
      case WarmUpStates.STAY_AWAY:
        spokenMessage =
            'But before we start, position yourself 3-5 feet away from your phone';
        imageAssetPath = 'assets/images/warmups/stay_away.png';
        break;
      case WarmUpStates.JOG:
        spokenMessage = 'For our first warm up, jogging in place';
        additionalExplanation =
            'Jogging in place is an aerobic exercise that requires you to constantly move and contract your muscles, which improves muscle strength,.... stability,.... and flexibility. You must use proper form in order to maximize the benefits of running in place.';
        imageAssetPath = 'assets/images/warmups/jogging.gif';
        break;
      case WarmUpStates.JOG_COUNTDOWN:
        spokenMessage = 'Are you ready?';
        imageAssetPath = 'assets/images/warmups/countdown_3.png';

        break;
      case WarmUpStates.JOG_DURATION:
        spokenMessage = 'Jog in place for 30 seconds.';
        additionalExplanation =
            '1. Stand straight with your feet a little wider than shoulder-width apart.  2. Bend the knees slightly and place your hands on the hips. 3.  Slowly rotate your hips, making big circles. 4. Complete a set in one direction and then switch to the opposite direction. 5.  dont force your self to do much if you are a novice or beginner. Good job continue your work.';
        imageAssetPath = 'assets/images/warmups/jogging.gif';
        break;
      case WarmUpStates.JOG_DONE:
        spokenMessage = 'DONE';
        break;
      case WarmUpStates.FIRST_REST:
        spokenMessage = 'Rest for 10 seconds. Prepare for the next exercise';
        imageAssetPath = 'assets/images/warmups/jumping_jack.gif';
        break;
      case WarmUpStates.JUMPING_JACK:
        spokenMessage = 'For our second warm up, jumping jacks';
        additionalExplanation =
            'Jumping jacks offer full-body exercise, working muscles in your arms, legs, and core. They can strengthen your muscles, improve coordination, and boost your fitness. You can add traditional jumping jacks to your workouts. ';
        imageAssetPath = 'assets/images/warmups/jumping_jack.gif';
        break;
      case WarmUpStates.JUMPING_JACK_COUNTDOWN:
        spokenMessage = 'Are you ready?';
        imageAssetPath = 'assets/images/warmups/countdown_3.png';
        break;
      case WarmUpStates.JUMPING_JACK_DURATION:
        spokenMessage = 'Do jumping jacks for 30 seconds. ';
        additionalExplanation =
            '1. Stand up straight, hold your arms at your sides, and stand with your feet shoulder-width apart 2. Jump and extend your arms overhead. 3. Extend your legs. and Land in the starting position.  4. dont force your self to do much if you are a novice or beginner.';
        imageAssetPath = 'assets/images/warmups/jumping_jack.gif';
        break;
      case WarmUpStates.JUMPING_JACK_DONE:
        spokenMessage = 'DONE';
        break;
      case WarmUpStates.SECOND_REST:
        spokenMessage = 'Rest for 10 seconds. Prepare for the next exercise';
        imageAssetPath = 'assets/images/warmups/hip_circle.gif';

        break;
      case WarmUpStates.HIP_CIRCLES:
        spokenMessage = 'For our last warm up, hip circles';
        additionalExplanation =
            'Hip circles involve rotating your hips in a circular motion. It helps to strengthen your hips and core muscles. It is beneficial for improving flexibility and balance.';
        imageAssetPath = 'assets/images/warmups/hip_circle.gif';
        break;
      case WarmUpStates.HIP_CIRCLES_COUNTDOWN:
        spokenMessage = 'Are you ready?';
        imageAssetPath = 'assets/images/warmups/countdown_3.png';
        break;
      case WarmUpStates.HIP_CIRCLES_DURATION:
        spokenMessage = 'Do hip circles for 30 seconds.';
        additionalExplanation = '';
        imageAssetPath = 'assets/images/warmups/hip_circle.gif';
        break;
      case WarmUpStates.HIP_CIRCLES_DONE:
        spokenMessage = 'DONE';
        break;
      case WarmUpStates.LAST_REST:
        spokenMessage = 'Rest for 30 seconds. Prepare for your main workout';
        break;
      case WarmUpStates.FINAL_REMINDER:
        spokenMessage =
            'For your main workout, the exercise will depend on what your trainer prescribed for you.';
        break;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _currentWarmUpState = _state;
    });
    playMessage();
  }
  //============================================================================

  @override
  void initState() {
    super.initState();
    SetCurrentWarmUpState(WarmUpStates.START);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.pause();
    flutterTts.stop();
    _timer.cancel();
    audioPlayer.dispose();
  }

  void playMessage() async {
    if (GetCurrentWarmUpState == WarmUpStates.JOG_DONE ||
        GetCurrentWarmUpState == WarmUpStates.JUMPING_JACK_DONE ||
        GetCurrentWarmUpState == WarmUpStates.HIP_CIRCLES_DONE) {
      await audioPlayer.play(AssetSource('audio/ding.mp3'));
    } else {
      await playback();
      //await flutterTts.awaitSpeakCompletion(true);
    }

    if (GetCurrentWarmUpState == WarmUpStates.JOG_COUNTDOWN ||
        GetCurrentWarmUpState == WarmUpStates.HIP_CIRCLES_COUNTDOWN ||
        GetCurrentWarmUpState == WarmUpStates.JUMPING_JACK_COUNTDOWN) {
      _initializeTimer(4);
    } else if (GetCurrentWarmUpState == WarmUpStates.FIRST_REST ||
        GetCurrentWarmUpState == WarmUpStates.SECOND_REST) {
      _initializeTimer(10);
    } else if (GetCurrentWarmUpState == WarmUpStates.JOG_DURATION ||
        GetCurrentWarmUpState == WarmUpStates.JUMPING_JACK_DURATION ||
        GetCurrentWarmUpState == WarmUpStates.HIP_CIRCLES_DURATION ||
        GetCurrentWarmUpState == WarmUpStates.LAST_REST) {
      flutterTts.speak(additionalExplanation);
      _initializeTimer(30);
    } else if (GetCurrentWarmUpState == WarmUpStates.JOG ||
        GetCurrentWarmUpState == WarmUpStates.JUMPING_JACK ||
        GetCurrentWarmUpState == WarmUpStates.HIP_CIRCLES) {
      await flutterTts.speak(additionalExplanation);
      await flutterTts.awaitSpeakCompletion(true);
      goToNextState();
    } else {
      await Future.delayed(Duration(seconds: 2));
      goToNextState();
    }
  }

  void goToNextState() async {
    if (GetCurrentWarmUpState == WarmUpStates.FINAL_REMINDER) {
      setState(() {
        _isDoneWarmingUp = true;
      });
    } else {
      int currentStateIndex = GetCurrentWarmUpState.index;
      SetCurrentWarmUpState(WarmUpStates.values[currentStateIndex + 1]);
    }
  }

  void _initializeTimer(int duration) {
    if (!mounted) {
      return;
    }
    setState(() {
      _secondsRemaining = duration;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          if (GetCurrentWarmUpState == WarmUpStates.JOG_COUNTDOWN ||
              GetCurrentWarmUpState == WarmUpStates.HIP_CIRCLES_COUNTDOWN ||
              GetCurrentWarmUpState == WarmUpStates.JUMPING_JACK_COUNTDOWN) {
            switch (_secondsRemaining) {
              case 3:
                imageAssetPath = 'assets/images/warmups/countdown_3.png';
                break;
              case 2:
                imageAssetPath = 'assets/images/warmups/countdown_2.png';
                break;
              case 1:
                imageAssetPath = 'assets/images/warmups/countdown_1.png';
                break;
            }
          }
        } else {
          _timer.cancel(); // Stop the timer when countdown reaches 0
          goToNextState();
        }
      });
    });
  }

  //  Text to Speech Functions
  //============================================================================
  Future playback() async {
    //await flutterTts.stop();
    await flutterTts
        .setLanguage('en-US'); // Set the language (adjust as needed)
    await flutterTts.setPitch(1.0); // Set pitch (adjust as needed)
    await flutterTts.setSpeechRate(0.5); // Set speech rate (adjust as needed)
    await flutterTts.speak(spokenMessage);
  }
  //============================================================================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await audioPlayer.stop();
        await flutterTts.pause();
        await flutterTts.stop();
        return true;
      },
      child: Scaffold(
        body: simulationBackgroundContainer(context,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: futuraText(
                            (GetCurrentWarmUpState != WarmUpStates.LAST_REST &&
                                    GetCurrentWarmUpState !=
                                        WarmUpStates.FINAL_REMINDER)
                                ? spokenMessage
                                : '',
                            textStyle: blackBoldStyle())),
                    if (GetCurrentWarmUpState != WarmUpStates.LAST_REST &&
                        GetCurrentWarmUpState != WarmUpStates.FINAL_REMINDER)
                      Stack(
                        children: [
                          Container(
                            height: 500,
                            width: 400,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(imageAssetPath))),
                          ),
                          if (GetCurrentWarmUpState ==
                                  WarmUpStates.HIP_CIRCLES_DONE ||
                              GetCurrentWarmUpState == WarmUpStates.JOG_DONE ||
                              GetCurrentWarmUpState ==
                                  WarmUpStates.JUMPING_JACK_DONE)
                            Container(
                              height: 500,
                              width: 400,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/warmups/DONE.png'))),
                            ),
                        ],
                      )
                    else
                      Container(
                          height: 500,
                          width: 400,
                          child: Center(
                              child: futuraText(spokenMessage,
                                  textStyle: greyBoldStyle(size: 30)))),
                    if (GetCurrentWarmUpState ==
                            WarmUpStates.HIP_CIRCLES_DURATION ||
                        GetCurrentWarmUpState == WarmUpStates.JOG_DURATION ||
                        GetCurrentWarmUpState ==
                            WarmUpStates.JUMPING_JACK_DURATION ||
                        GetCurrentWarmUpState == WarmUpStates.FIRST_REST ||
                        GetCurrentWarmUpState == WarmUpStates.SECOND_REST ||
                        GetCurrentWarmUpState == WarmUpStates.LAST_REST)
                      futuraText(
                          _secondsRemaining > 0
                              ? _secondsRemaining.toString()
                              : '',
                          textStyle: blackBoldStyle(size: 75))
                    else if (_isDoneWarmingUp)
                      ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed('/cameraWorkoutScreen'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: futuraText('START MAIN WORKOUT',
                              textStyle: whiteBoldStyle()))
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
