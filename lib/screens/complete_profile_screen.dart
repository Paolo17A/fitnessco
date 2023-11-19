import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/log_out_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/fitnessco_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/dropdown_widget.dart';

enum ProfileScreenPhases { BIOMETRICS, HEALTH, WORKOUT }

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  bool _isLoading = false;
  ProfileScreenPhases currentPhase = ProfileScreenPhases.BIOMETRICS;

  //  BIOMETRICS
  final _ageController = TextEditingController();
  String sex = '';
  List<String> sexChoices = ['MALE', 'FEMALE'];
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  double BMI = 0;
  String workoutExperience = '';
  List<String> workoutExperiences = [
    'NO EXPERIENCE',
    'NOVICE',
    'AMATEUR',
    'EXPERIENCED',
    'ATHLETE'
  ];
  final _workoutFrequencyController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _workoutAvailabilityController = TextEditingController();

  //  HEALTH CONCERNS
  final _illnessController = TextEditingController();
  final _allergiesController = TextEditingController();
  bool _recentlyDoctor = false;
  final _injuriesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _steroidsController = TextEditingController();
  var currentDiet = '';
  List<String> dietChoices = ['CARNIVORE', 'VEGETARIAN', 'ALL-AROUND'];

  //WORKOUT
  String bodyConcern = '';
  List<String> bodyConcernChoices = [
    'WEIGHT LOSS',
    'WEIGHT GAIN',
    'ATHLETICISM'
  ];
  String muscleGoal = '';
  List<String> muscleGoalChoices = [
    'UPPER BODY',
    'CORE',
    'LEGS',
    'BUTTOCKS',
    'WHOLE BODY'
  ];
  String dedicationSpan = '';
  List<String> dedicationSpanChoices = [
    '1 MONTH',
    '3 MONTHS',
    '6 MONTHS',
    'FULL-TIME TRAINING'
  ];
  final _specialPlansController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _heightController.addListener(() => calculateBMI());
    _weightController.addListener(() => calculateBMI());
  }

  void calculateBMI() {
    if (_heightController.text.isEmpty ||
        double.tryParse(_heightController.text) == null ||
        _weightController.text.isEmpty ||
        double.tryParse(_weightController.text) == null) {
      return;
    }
    double height = double.parse(_heightController.text);
    double weight = double.parse(_weightController.text);
    setState(() {
      BMI = double.parse((weight / (height * height)).toStringAsFixed(2));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _workoutFrequencyController.dispose();
    _workoutAvailabilityController.dispose();
    _sleepHoursController.dispose();
    _illnessController.dispose();
    _allergiesController.dispose();
    _injuriesController.dispose();
    _medicationsController.dispose();
    _steroidsController.dispose();
    _specialPlansController.dispose();
  }

  void handleContinueButtonPress() {
    FocusScope.of(context).unfocus();
    switch (currentPhase) {
      case ProfileScreenPhases.BIOMETRICS:
        if (_ageController.text.isEmpty ||
            sex == '' ||
            _heightController.text.isEmpty ||
            _weightController.text.isEmpty ||
            workoutExperience == '' ||
            _workoutFrequencyController.text.isEmpty ||
            _sleepHoursController.text.isEmpty ||
            _workoutAvailabilityController.text.isEmpty) {
          showErrorMessage(context, label: 'Please fill up all the fields');
          return;
        }
        setState(() {
          currentPhase = ProfileScreenPhases.HEALTH;
        });
        break;
      case ProfileScreenPhases.HEALTH:
        if (_illnessController.text.isEmpty ||
            _allergiesController.text.isEmpty ||
            _injuriesController.text.isEmpty ||
            _medicationsController.text.isEmpty ||
            _steroidsController.text.isEmpty ||
            currentDiet == '') {
          showErrorMessage(context, label: 'Please fill up all the fields');
          return;
        }
        setState(() {
          currentPhase = ProfileScreenPhases.WORKOUT;
        });
        break;
      case ProfileScreenPhases.WORKOUT:
        if (bodyConcern == '' || muscleGoal == '' || dedicationSpan == '') {
          showErrorMessage(context,
              label: 'Please fill up all the dropdown fields');
          return;
        }
        uploadProfileData();
        break;
    }
  }

  Future uploadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await getCurrentUserData();
      List<dynamic> bmiEntries = userData['bmiHistory'];
      Map<dynamic, dynamic> newBMI = {
        'dateTime': {
          'month': DateTime.now().month,
          'year': DateTime.now().year,
          'day': DateTime.now().day
        },
        'bmiValue': BMI
      };

      bmiEntries.add(newBMI);

      await updateCurrentUserData({
        'bmiHistory': bmiEntries,
        'accountInitialized': true,
        'profileDetails': {
          'age': double.parse(_ageController.text),
          'sex': sex,
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'workoutExperience': workoutExperience,
          'workoutFrequency': int.parse(_workoutFrequencyController.text),
          'sleepHours': double.parse(_sleepHoursController.text),
          'workoutAvailability': _workoutAvailabilityController.text,
          'illnesses': _illnessController.text,
          'allergies': _allergiesController.text,
          'recentlyDoctored': _recentlyDoctor,
          'injuries': _injuriesController.text,
          'medications': _medicationsController.text,
          'steroids': _steroidsController.text,
          'foodDiet': currentDiet,
          'bodyConcerns': bodyConcern,
          'muscleGoal': muscleGoal,
          'dedicationSpan': dedicationSpan,
          'specialPlans': _specialPlansController.text
        }
      });

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed('/profileCompleted');
    } catch (error) {
      showErrorMessage(context, label: 'Error uploading profile data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPhase == ProfileScreenPhases.BIOMETRICS) {
          showLogOutDialog(context, () async {
            await FirebaseAuth.instance.signOut();
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            sharedPreferences.remove('email');
            sharedPreferences.remove('password');
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
        setState(() {
          if (currentPhase == ProfileScreenPhases.WORKOUT) {
            currentPhase = ProfileScreenPhases.HEALTH;
          } else if (currentPhase == ProfileScreenPhases.HEALTH) {
            currentPhase = ProfileScreenPhases.BIOMETRICS;
          }
        });
        return false;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: stackedLoadingContainer(context, _isLoading, [
            userAuthBackgroundContainer(context,
                child: SafeArea(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _completeProfileHeader(),
                      _progressBar(),
                      _currentProfileFields(),
                      _continueButton()
                    ],
                  ),
                )))
          ]),
        ),
      ),
    );
  }

  Widget _completeProfileHeader() {
    return Column(children: [
      futuraText('PLEASE COMPLETE YOUR PROFILE',
          textStyle: blackBoldStyle(size: 21)),
      futuraText(
          currentPhase == ProfileScreenPhases.BIOMETRICS
              ? 'BASIC BIOMETRICS'
              : currentPhase == ProfileScreenPhases.HEALTH
                  ? 'HEALTH CONCERNS'
                  : 'WORKOUT PLAN',
          textStyle: whiteBoldStyle())
    ]);
  }

  Widget _progressBar() {
    return Stack(children: [
      Divider(
        thickness: 5,
        color: Colors.black,
      ),
      Row(children: [
        Container(
          width: MediaQuery.of(context).size.width *
              ((currentPhase.index + 1) * 0.33),
          height: 20,
          color: CustomColors.nearMoon,
        )
      ])
    ]);
  }

  Widget _currentProfileFields() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: roundedContainer(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: currentPhase == ProfileScreenPhases.BIOMETRICS
                  ? _biometricsContainer()
                  : currentPhase == ProfileScreenPhases.HEALTH
                      ? _healthContainer()
                      : _workoutContainer())),
    );
  }

  Widget _continueButton() {
    return gradientOvalButton(
        label: 'CONTINUE',
        width: 250,
        onTap: () => handleContinueButtonPress());
  }

  Widget _biometricsContainer() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 50,
            child: fitnesscoTextField(
                'AGE', TextInputType.number, _ageController,
                typeColor: Colors.black),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: dropdownWidget(sex, (newValue) {
                setState(() {
                  sex = newValue!;
                });
              }, sexChoices, 'SEX', false))
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: fitnesscoTextField(
                  'HEIGHT (in M)',
                  TextInputType.numberWithOptions(decimal: true),
                  _heightController,
                  typeColor: Colors.black),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: fitnesscoTextField(
                  'WEIGHT (in KG)',
                  TextInputType.numberWithOptions(decimal: true),
                  _weightController,
                  typeColor: Colors.black),
            )
          ],
        ),
      ),
      borderedTextContainer('BMI', BMI.toString()),
      const SizedBox(height: 20),
      dropdownWidget(workoutExperience, (newValue) {
        setState(() {
          workoutExperience = newValue!;
        });
      }, workoutExperiences, 'WORKOUT EXPERIENCE', false),
      Row(children: [futuraText('How many times a week do you workout?')]),
      fitnesscoTextField('WORKOUT FREQUENCY', TextInputType.number,
          _workoutFrequencyController,
          typeColor: Colors.black),
      const SizedBox(height: 20),
      Row(children: [
        futuraText('How many hours of sleep do you normally get?')
      ]),
      fitnesscoTextField('', TextInputType.number, _sleepHoursController,
          typeColor: Colors.black),
      const SizedBox(height: 20),
      Row(children: [futuraText('What is your workout availabilty?')]),
      fitnesscoTextField(
          '', TextInputType.multiline, _workoutAvailabilityController,
          maxLines: 2, typeColor: Colors.black)
    ]);
  }

  Widget _healthContainer() {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField('Do you have any current illnesses?',
            TextInputType.text, _illnessController,
            typeColor: Colors.black),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField('Do you have any allergies?',
            TextInputType.text, _allergiesController,
            typeColor: Colors.black),
      ),
      CheckboxListTile(
          value: _recentlyDoctor,
          onChanged: ((value) {
            setState(() {
              _recentlyDoctor = value!;
            });
          }),
          title: futuraText('Went to a doctor in the last 15-30 days?')),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField('Any current or recent injuries?',
            TextInputType.text, _injuriesController,
            typeColor: Colors.black),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField('Taking any medications now?',
            TextInputType.text, _medicationsController,
            typeColor: Colors.black),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: fitnesscoTextField('Any gym drug-related substances?',
            TextInputType.text, _steroidsController,
            typeColor: Colors.black),
      ),
      Row(children: [futuraText('What is your current food diet?')]),
      dropdownWidget(currentDiet, (newValue) {
        setState(() {
          currentDiet = newValue!;
        });
      }, dietChoices, '', false)
    ]);
  }

  Widget _workoutContainer() {
    return Column(children: [
      Row(children: [futuraText('What is your body concern?')]),
      dropdownWidget(bodyConcern, (newValue) {
        setState(() {
          bodyConcern = newValue!;
        });
      }, bodyConcernChoices, '', false),
      Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: futuraText(
                  'What part of the muscle or body do you want to improve?',
                  textAlign: TextAlign.left))
        ],
      ),
      dropdownWidget(muscleGoal, (newValue) {
        setState(() {
          muscleGoal = newValue!;
        });
      }, muscleGoalChoices, '', false),
      Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: futuraText(
                  'How much time are you willing to dedicate for fitness?',
                  textAlign: TextAlign.left))
        ],
      ),
      dropdownWidget(dedicationSpan, (newValue) {
        setState(() {
          dedicationSpan = newValue!;
        });
      }, dedicationSpanChoices, '', false),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: futuraText(
                    'Elaborate some specific body plans for your trainer (Trainers can see this as you send them a training request)',
                    textAlign: TextAlign.justify))
          ],
        ),
      ),
      fitnesscoTextField('', TextInputType.multiline, _specialPlansController,
          typeColor: Colors.black)
    ]);
  }
}
