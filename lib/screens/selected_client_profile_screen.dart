import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/MembershipStatusDropdown_widget.dart';
import 'package:fitnessco/widgets/app_bar_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/gym_history_entry_widget.dart';
import 'package:fitnessco/widgets/payment_interval_dropdown_widget.dart';
import 'package:flutter/material.dart';

class SelectedClientProfile extends StatefulWidget {
  final String clientUID;

  const SelectedClientProfile({Key? key, required this.clientUID})
      : super(key: key);

  @override
  _SelectedClientProfileState createState() => _SelectedClientProfileState();
}

class _SelectedClientProfileState extends State<SelectedClientProfile> {
  bool _isLoading = true;
  bool viewedByAdmin = false;

  //GENERAL
  String _profileImageURL = '';
  double currentBMI = 0;
  String firstName = '';
  String lastName = '';
  num age = 0;
  String sex = '';
  num height = 0;
  num weight = 0;

  //  ADMIN VIEW
  String _selectedMembershipStatus = 'UNPAID';
  String _selectedPaymentInterval = 'DAILY';
  bool _currentlyUsingGym = false;
  List<dynamic> gymHistory = [];

  //  TRAINER VIEW
  String workoutExperience = '';
  num workoutFrequency = 0;
  num sleepHours = 0;
  String workoutAvailability = '';
  String illnesses = '';
  String allergies = '';
  bool recentlyDoctored = false;
  String injuries = '';
  String medications = '';
  String steroids = '';
  String foodDiet = '';
  String bodyConcerns = '';
  String muscleGoal = '';
  String dedicationSpan = '';
  String specialPlans = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future _fetchUserData() async {
    try {
      final currentUser = await getCurrentUserData();
      viewedByAdmin = currentUser['accountType'] == 'ADMIN';

      final thisUser = await getThisUserData(widget.clientUID);
      final thisUserData = thisUser.data() as Map<dynamic, dynamic>;
      _selectedMembershipStatus = thisUserData['membershipStatus'] as String;
      final profileDetails = thisUserData['profileDetails'];
      firstName = thisUserData['firstName'];
      lastName = thisUserData['lastName'];
      age = profileDetails['age'];
      sex = profileDetails['sex'];
      height = profileDetails['height'];
      weight = profileDetails['weight'];

      if (!thisUserData.containsKey('paymentInterval')) {
        await updateThisUserData(
            widget.clientUID, {'paymentInterval': _selectedPaymentInterval});
      } else {
        _selectedPaymentInterval = thisUserData['paymentInterval'];
      }

      gymHistory = thisUserData['gymHistory'];
      _profileImageURL = thisUserData['profileImageURL'];
      final bmiHistory = (thisUserData['bmiHistory'] as List<dynamic>);
      if (bmiHistory.isNotEmpty) {
        currentBMI =
            (thisUserData['bmiHistory'] as List<dynamic>).last['bmiValue'];
      }

      workoutExperience = profileDetails['workoutExperience'];
      workoutFrequency = profileDetails['workoutFrequency'];
      sleepHours = profileDetails['sleepHours'];
      workoutAvailability = profileDetails['workoutAvailability'];

      illnesses = profileDetails['illnesses'];
      allergies = profileDetails['allergies'];
      recentlyDoctored = profileDetails['recentlyDoctored'];
      injuries = profileDetails['injuries'];
      medications = profileDetails['medications'];
      steroids = profileDetails['steroids'];
      foodDiet = profileDetails['foodDiet'];
      bodyConcerns = profileDetails['bodyConcerns'];
      muscleGoal = profileDetails['muscleGoal'];
      dedicationSpan = profileDetails['dedicationSpan'];
      specialPlans = profileDetails['specialPlans'];

      if (gymHistory.isNotEmpty) {
        _currentlyUsingGym = (gymHistory[gymHistory.length - 1]['timeOut']
                as Map<dynamic, dynamic>)
            .isEmpty;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error getting selecter user data.');
    }
  }

  void _saveMembershipStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Duration extensionTime = Duration.zero;
      switch (_selectedPaymentInterval) {
        case 'DAILY':
          extensionTime = Duration(days: 1);
          break;
        case 'WEEKLY':
          extensionTime = Duration(days: 7);
          break;
        case 'MONTHLY':
          extensionTime = Duration(days: 30);
          break;
        case 'DOWN WEEKLY':
          extensionTime = Duration(days: 3);
          break;
        case 'DOWN WEEKLY':
          extensionTime = Duration(days: 15);
          break;
      }
      await updateThisUserData(widget.clientUID, {
        'membershipStatus': _selectedMembershipStatus,
        'paymentInterval': _selectedPaymentInterval,
        'expiryDate': DateTime.now().add(extensionTime)
      });
      await _fetchUserData();
      showSuccessMessage(context,
          label: 'Client Profile Saved Successfully.',
          onPress: () => Navigator.of(context).pop());
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error saving membership status.');
    }
  }

  void _removeClient() async {
    try {
      //  Delete the message thread
      final messageThread = await FirebaseFirestore.instance
          .collection('messages')
          .where('trainerUID',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('clientUID', isEqualTo: widget.clientUID)
          .get();
      if (messageThread.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(messageThread.docs[0].id)
            .delete();
      } else {
        return;
      }

      //  Remove the trainer from the client's user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientUID)
          .update({'currentTrainer': '', 'isConfirmed': false});

      //  Remove the client from the trainer's current clients
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'currentClients': FieldValue.arrayRemove([widget.clientUID]),
      });

      //  call the callback widget and return to the client home screen
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/trainerCurrentClients');
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error removing trainer.')));
    }
  }

  //  TIMING IN/OUT
  //============================================================================
  void _timeInClient() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> timeEntry = {
        'timeIn': {
          'month': DateTime.now().month,
          'year': DateTime.now().year,
          'day': DateTime.now().day,
          'hour': DateTime.now().hour,
          'minute': DateTime.now().minute,
          'second': DateTime.now().second
        },
        'timeOut': {}
      };
      gymHistory.add(timeEntry);
      await updateThisUserData(widget.clientUID, {'gymHistory': gymHistory});
      setState(() {
        _isLoading = false;
        _currentlyUsingGym = true;
      });
      showSuccessMessage(context,
          label: 'Successfully timed user in.',
          onPress: () => Navigator.of(context).pop());
      setState(() {});
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error timing client in.');
    }
  }

  void _timeOutClient() async {
    try {
      setState(() {
        _isLoading = true;
      });
      gymHistory[gymHistory.length - 1]['timeOut'] = {
        'month': DateTime.now().month,
        'year': DateTime.now().year,
        'day': DateTime.now().day,
        'hour': DateTime.now().hour,
        'minute': DateTime.now().minute,
        'second': DateTime.now().second
      };

      await updateThisUserData(widget.clientUID, {'gymHistory': gymHistory});
      showSuccessMessage(context,
          label: 'Successfully timed user out!',
          onPress: () => Navigator.of(context).pop());
      setState(() {
        _isLoading = false;
        _currentlyUsingGym = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error timing client out.');
    }
  }

//==============================================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: largeGradientAppBar('All Clients'),
          body: switchedLoadingContainer(
            _isLoading,
            viewTrainerBackgroundContainer(
              context,
              child: SafeArea(
                child: Column(children: [
                  _clientGeneralData(),
                  viewedByAdmin
                      ? _adminAccessibleData()
                      : _trainerAccessibleData()
                ]),
              ),
            ),
          )),
    );
  }

  Widget _clientGeneralData() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  buildProfileImage(
                      profileImageURL: _profileImageURL, radius: 50),
                  const SizedBox(height: 15),
                  Text(currentBMI.toString(),
                      style: TextStyle(
                          fontSize: 35,
                          color: CustomColors.nearMoon,
                          fontWeight: FontWeight.bold)),
                  futuraText('CURRENT BMI',
                      textStyle: TextStyle(color: Colors.grey))
                ],
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(children: [
                  futuraText('$firstName $lastName',
                      textStyle: blackBoldStyle()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      futuraText('Age: $age',
                          textStyle: greyBoldStyle(size: 15)),
                      const SizedBox(width: 10),
                      futuraText(sex,
                          textStyle: TextStyle(
                              color: CustomColors.nearMoon,
                              fontWeight: FontWeight.bold,
                              fontSize: 15))
                    ],
                  ),
                  const SizedBox(height: 20),
                  futuraText('Height: $height meters'),
                  futuraText('Weight: $weight KG'),
                  const SizedBox(height: 10),
                ]))
          ]),
    );
  }

  Widget _adminAccessibleData() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          MembershipStatusDropdown(
              selectedMembershipStatus: _selectedMembershipStatus,
              onChanged: (String? newValue) {
                _selectedMembershipStatus = newValue!;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: PaymentIntervalDropdownWidget(
                selectedPaymentInterval: _selectedPaymentInterval,
                onChanged: (String? newValue) {
                  _selectedPaymentInterval = newValue!;
                }),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: _saveMembershipStatus,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: futuraText('SAVE', textStyle: whiteBoldStyle(size: 15)),
            ),
          ),
          Text('Gym Usage History',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          roundedContainer(
            color: CustomColors.love,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  futuraText('Gym Usage History',
                      textStyle: blackBoldStyle(size: 25)),
                  roundedContainer(
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: gymHistory.length,
                        itemBuilder: (context, index) {
                          return gymHistoryEntryWidget(
                              gymHistory[index]['timeIn'],
                              gymHistory[index]['timeOut']);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                          onPressed: () {
                            _currentlyUsingGym
                                ? _timeOutClient()
                                : _timeInClient();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Text(
                            _currentlyUsingGym ? 'TIME OUT' : 'TIME IN',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  Widget _trainerAccessibleData() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(children: [
          TabBar(tabs: [
            Tab(
                child: futuraText('BASIC BIOMETRICS',
                    textStyle: blackBoldStyle(size: 10))),
            Tab(
                child: futuraText('HEALTH CONCERNS',
                    textStyle: blackBoldStyle(size: 10))),
            Tab(
                child: futuraText('WORKOUT PLANS',
                    textStyle: blackBoldStyle(size: 10))),
          ]),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(children: [
              _basicBiometrics(),
              _healthConcerns(),
              _workoutPlans()
            ]),
          )
        ]));
  }

  Widget _basicBiometrics() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('WORKOUT EXPERIENCE: '),
            const SizedBox(width: 10),
            futuraText(workoutExperience, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('WORKOUT FREQUENCY: '),
            const SizedBox(width: 10),
            futuraText('$workoutFrequency a week',
                textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('NORMAL SLEEP HOURS: '),
            const SizedBox(width: 10),
            futuraText('$sleepHours Hours', textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('WORKOUT TIME AVAILABILITY: '),
            const SizedBox(width: 10),
            futuraText(workoutAvailability, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider()
    ]);
  }

  Widget _healthConcerns() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('HAVE ILLNESSES?: '),
            const SizedBox(width: 10),
            futuraText(illnesses, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('ANY ALLERGIES: '),
            const SizedBox(width: 10),
            futuraText(allergies, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('GOT TO A DOCTOR IN THE LAST 30 DAYS? '),
            const SizedBox(width: 10),
            futuraText(recentlyDoctored ? 'YES' : 'NO',
                textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('ANY PAST OR CURRENT INJURIES?: '),
            const SizedBox(width: 10),
            futuraText(injuries, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('TAKING SOME MEDICATIONS?: '),
            const SizedBox(width: 10),
            futuraText(medications, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('TAKEN SOME GYM-RELATED DRUGS?: '),
            const SizedBox(width: 10),
            futuraText(steroids, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('FOOD DIET: '),
            const SizedBox(width: 10),
            futuraText(foodDiet, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider()
    ]);
  }

  Widget _workoutPlans() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('BODY CONCERN: '),
            const SizedBox(width: 10),
            futuraText(bodyConcerns, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('WHAT YOU WANT TO IMPROVE?: '),
            const SizedBox(width: 10),
            futuraText(muscleGoal, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            futuraText('DEDICATED WORKOUT DATES: '),
            const SizedBox(width: 10),
            futuraText(dedicationSpan, textStyle: blackBoldStyle(size: 12))
          ],
        ),
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(10),
        child: futuraText(
            'ELABORATE SOME SPECIFIC BODY PLANS FOR YOUR TRAINER TO SEE',
            textStyle: blackBoldStyle(size: 10)),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: roundedContainer(
            color: CustomColors.love,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: SingleChildScrollView(
                  child: futuraText(specialPlans, textAlign: TextAlign.left)),
            )),
      )
    ]);
  }
}
