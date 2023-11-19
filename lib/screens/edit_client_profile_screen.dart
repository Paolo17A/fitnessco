import 'dart:io';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/utils/remove_pic_dialogue.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/dropdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/fitnessco_textfield_widget.dart';

class EditClientProfile extends StatefulWidget {
  const EditClientProfile({Key? key}) : super(key: key);

  @override
  _EditClientProfileState createState() => _EditClientProfileState();
}

class _EditClientProfileState extends State<EditClientProfile> {
  bool _isLoading = true;

  File? _imageFile;
  ImagePicker imagePicker = ImagePicker();
  String _profileImageURL = '';
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  double currentBMI = 0;
  String _firstName = "";
  String _lastName = "";
  String _sex = '';
  List<String> sexChoices = ['MALE', 'FEMALE'];
  final _ageController = TextEditingController();

  //  BASIC BIOMETRICS
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  String _workoutExperience = '';
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
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userData = await getCurrentUserData();
      _profileImageURL = userData['profileImageURL'] as String;
      currentBMI = (userData['bmiHistory'] as List<dynamic>).last['bmiValue'];

      _firstName = userData['firstName'] ?? "";
      _firstNameController.text = _firstName;

      _lastName = userData['lastName'] ?? "";
      _lastNameController.text = _lastName;

      _sex = userData['profileDetails']['sex'];
      _ageController.text =
          (userData['profileDetails']['age']).toInt().toString();
      _heightController.text = userData['profileDetails']['height'].toString();
      _weightController.text = userData['profileDetails']['weight'].toString();
      _workoutExperience = userData['profileDetails']['workoutExperience'];
      _workoutFrequencyController.text =
          userData['profileDetails']['workoutFrequency'].toString();
      _sleepHoursController.text =
          (userData['profileDetails']['sleepHours']).toString();
      _workoutAvailabilityController.text =
          userData['profileDetails']['workoutAvailability'];
      _illnessController.text = userData['profileDetails']['illnesses'];
      _allergiesController.text = userData['profileDetails']['allergies'];
      _recentlyDoctor = userData['profileDetails']['recentlyDoctored'];
      _injuriesController.text = userData['profileDetails']['injuries'];
      _medicationsController.text = userData['profileDetails']['medications'];
      _steroidsController.text = userData['profileDetails']['steroids'];
      currentDiet = userData['profileDetails']['foodDiet'];
      bodyConcern = userData['profileDetails']['bodyConcerns'];
      muscleGoal = userData['profileDetails']['muscleGoal'];
      dedicationSpan = userData['profileDetails']['dedicationSpan'];
      _specialPlansController.text = userData['profileDetails']['specialPlans'];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        showErrorMessage(context, label: 'Error getting user data');
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      _firstName = _firstNameController.text.isNotEmpty
          ? _firstNameController.text
          : _firstName;
      _lastName = _lastNameController.text.isNotEmpty
          ? _lastNameController.text
          : _lastName;

      await updateCurrentUserData({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'profileDetails': {
          'age': double.parse(_ageController.text),
          'sex': _sex,
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'workoutExperience': _workoutExperience,
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

      if (_imageFile != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profilePics')
            .child(FirebaseAuth.instance.currentUser!.uid);

        final uploadTask = storageRef.putFile(_imageFile!);
        final taskSnapshot = await uploadTask.whenComplete(() {});

        //let the download URL of the uploaded image
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // Update the user's data in Firestore with the image URL
        await updateCurrentUserData({
          'profileImageURL': downloadURL,
        });
      }
      setState(() {
        _isLoading = false;
      });

      showSuccessMessage(context,
          label: 'Profile information saved successfully', onPress: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/clientHome');
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        showErrorMessage(context, label: 'Error updating user profile');
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);

      final uploadTask = storageRef.putFile(_imageFile!);
      final taskSnapshot = await uploadTask.whenComplete(() {});

      //let the download URL of the uploaded image
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the user's data in Firestore with the image URL
      await updateCurrentUserData({
        'profileImageURL': downloadURL,
      });
      setState(() {
        _profileImageURL = downloadURL;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeProfilePic() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await updateCurrentUserData({
        'profileImageURL': '',
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);

      await storageRef.delete();

      setState(() {
        _imageFile = null;
        _profileImageURL = '';
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error removing profile pic')));
      setState(() {
        _imageFile = null;
        _profileImageURL = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/clientHome');
        return true;
      },
      child: DefaultTabController(
          length: 4,
          child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Center(
                  child: futuraText('Edit Profile Description',
                      textStyle: whiteBoldStyle(size: 25)),
                ),
              ),
              body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: switchedLoadingContainer(
                      _isLoading,
                      userAuthBackgroundContainer(context,
                          child: Column(children: [
                            const SizedBox(height: 50),
                            Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _profileImageContainer(),
                                            _bmiContainer()
                                          ])),
                                  _profileTabs(),
                                  _confirmChangesButton()
                                ]))
                          ])))))),
    );
  }

  Widget _profileImageContainer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Row(children: [
        buildProfileImage(profileImageURL: _profileImageURL, radius: 50),
        const SizedBox(width: 10),
        SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: futuraText('UPLOAD',
                        textStyle: TextStyle(fontSize: 14)),
                  )),
              if (_profileImageURL.isNotEmpty)
                SizedBox(
                  height: 25,
                  child: ElevatedButton(
                      onPressed: () => removeProfilePicDialogue(context,
                          onRemove: _removeProfilePic),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: futuraText('REMOVE',
                          textStyle: TextStyle(fontSize: 10))),
                ),
            ],
          ),
        )
      ]),
    );
  }

  Widget _bmiContainer() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.33,
        child: Column(children: [
          Text(currentBMI.toString(),
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 30,
            child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/bmiHistory'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: futuraText('Update BMI',
                    textStyle: TextStyle(fontSize: 12))),
          )
        ]));
  }

  Widget _profileTabs() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: roundedContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          color: CustomColors.love.withOpacity(0.4),
          child: Column(
            children: [
              SizedBox(
                width: double.maxFinite,
                child: TabBar(tabs: [
                  Tab(
                      child: futuraText('PROFILE',
                          textStyle: blackBoldStyle(size: 10))),
                  Tab(
                      child: futuraText('BASIC\nBIOMETRICS',
                          textStyle: blackBoldStyle(size: 8))),
                  Tab(
                      child: futuraText('HEALTH CONCERNS',
                          textStyle: blackBoldStyle(size: 9))),
                  Tab(
                      child: futuraText('WORKOUT PLANS',
                          textStyle: blackBoldStyle(size: 9))),
                ]),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(children: [
                  _profileFields(),
                  _biometricsFields(),
                  _healthFields(),
                  _workoutFields()
                ]),
              )
            ],
          )),
    );
  }

  Widget _confirmChangesButton() {
    return gradientOvalButton(
        label: 'CONFIRM CHANGES',
        width: 250,
        height: 40,
        onTap: () => _updateProfile());
  }

  Widget _profileFields() {
    return Container(
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [futuraText('FIRST NAME')],
            ),
            SizedBox(
              height: 30,
              child: fitnesscoTextField(
                  'First Name', TextInputType.name, _firstNameController,
                  typeColor: Colors.black),
            ),
            const SizedBox(height: 30),
            Row(children: [futuraText('LAST NAME')]),
            SizedBox(
              height: 30,
              child: fitnesscoTextField(
                  'Last Name', TextInputType.name, _lastNameController,
                  typeColor: Colors.black),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    futuraText('SEX'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 30,
                      child: dropdownWidget(_sex, (val) {
                        setState(() {
                          _sex = val!;
                        });
                      }, sexChoices, _sex, false, padding: 0),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    futuraText('AGE'),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 30,
                        child: fitnesscoTextField(
                            'AGE',
                            TextInputType.numberWithOptions(decimal: false),
                            _ageController,
                            typeColor: Colors.black))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _biometricsFields() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  futuraText('HEIGHT'),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 30,
                      child: fitnesscoTextField(
                          'HEIGHT',
                          TextInputType.numberWithOptions(decimal: true),
                          _heightController,
                          typeColor: Colors.black))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  futuraText('WEIGHT'),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 30,
                      child: fitnesscoTextField(
                          'WEIGHT',
                          TextInputType.numberWithOptions(decimal: false),
                          _weightController,
                          typeColor: Colors.black))
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [futuraText('WORKOUT EXPERIENCE')]),
          dropdownWidget(_workoutExperience, (val) {
            setState(() {
              _workoutExperience = val!;
            });
          }, workoutExperiences, _workoutExperience, false),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  futuraText('WORKOUT FREQUENCY'),
                  SizedBox(
                    height: 40,
                    child: fitnesscoTextField(
                        'WORKOUT FREQUENCY',
                        TextInputType.numberWithOptions(decimal: false),
                        _workoutFrequencyController,
                        typeColor: Colors.black),
                  )
                ],
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              futuraText('NORMAL SLEEP HOURS'),
              SizedBox(
                height: 40,
                child: fitnesscoTextField('NORMAL SLEEP HOURS',
                    TextInputType.number, _sleepHoursController,
                    typeColor: Colors.black),
              )
            ],
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  futuraText('WORKOUT AVAILABILITY'),
                  SizedBox(
                    height: 40,
                    child: fitnesscoTextField('WORKOUT AVAILABILITY',
                        TextInputType.text, _workoutAvailabilityController,
                        typeColor: Colors.black),
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _healthFields() {
    return Container(
      width: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Column(children: [
                              futuraText('HAVE ILLNESSES?'),
                              SizedBox(
                                height: 30,
                                child: fitnesscoTextField(
                                    '', TextInputType.text, _illnessController,
                                    typeColor: Colors.black),
                              )
                            ])),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(children: [
                              futuraText('ANY ALLERGIES?'),
                              SizedBox(
                                height: 30,
                                child: fitnesscoTextField('',
                                    TextInputType.text, _allergiesController,
                                    typeColor: Colors.black),
                              )
                            ]))
                      ])
                ])),
            CheckboxListTile(
                value: _recentlyDoctor,
                onChanged: ((value) {
                  setState(() {
                    _recentlyDoctor = value!;
                  });
                }),
                title: futuraText('Went to a doctor in the last 15-30 days?')),
            Row(children: [futuraText('ANY PAST OR CURRENT INJURIES?')]),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                height: 30,
                child: fitnesscoTextField('Any current or recent injuries?',
                    TextInputType.text, _injuriesController,
                    typeColor: Colors.black),
              ),
            ),
            Row(children: [futuraText('TAKING SOME MEDICATIONS NOW?')]),
            SizedBox(
              height: 30,
              child: fitnesscoTextField(
                  '', TextInputType.text, _medicationsController,
                  typeColor: Colors.black),
            ),
            Row(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: futuraText(
                      'HAVE TAKEN SOME GYM-DRUG RELATED SUBSTANCE?',
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(fontSize: 14)))
            ]),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                height: 30,
                child: fitnesscoTextField(
                    '', TextInputType.text, _steroidsController,
                    typeColor: Colors.black),
              ),
            ),
            Row(children: [futuraText('What is your current food diet?')]),
            SizedBox(
              height: 30,
              child: dropdownWidget(currentDiet, (newValue) {
                setState(() {
                  currentDiet = newValue!;
                });
              }, dietChoices, currentDiet, false, padding: 0),
            )
          ],
        ),
      ),
    );
  }

  Widget _workoutFields() {
    return Container(
        width: double.maxFinite,
        child: Padding(
            padding: EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              futuraText('What is your body concern?',
                  textStyle: TextStyle(fontSize: 12)),
              SizedBox(
                height: 50,
                child: dropdownWidget(bodyConcern, (newValue) {
                  setState(() {
                    bodyConcern = newValue!;
                  });
                }, bodyConcernChoices, bodyConcern, false),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: futuraText(
                      'What part of the muscle or body do you want to improve?',
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(fontSize: 12))),
              SizedBox(
                height: 50,
                child: dropdownWidget(muscleGoal, (newValue) {
                  setState(() {
                    muscleGoal = newValue!;
                  });
                }, muscleGoalChoices, muscleGoal, false),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: futuraText(
                      'How much time are you willing to dedicate for fitness?',
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(fontSize: 12))),
              SizedBox(
                height: 50,
                child: dropdownWidget(dedicationSpan, (newValue) {
                  setState(() {
                    dedicationSpan = newValue!;
                  });
                }, dedicationSpanChoices, dedicationSpan, false),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: futuraText(
                      'Elaborate some specific body plans for your trainer (Trainers can see this as you send them a training request)',
                      textAlign: TextAlign.justify,
                      textStyle: TextStyle(fontSize: 12))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: fitnesscoTextField(
                    '', TextInputType.multiline, _specialPlansController,
                    typeColor: Colors.black, maxLines: 3),
              )
            ])));
  }
}
