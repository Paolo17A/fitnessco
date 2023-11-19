import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/home_app_bar_widget.dart';
import 'package:flutter/material.dart';
import '../utils/quit_dialogue_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  bool _isLoading = true;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _address = '';
  String _contactNumber = '';
  String _profileImageURL = '';
  List<dynamic> _currentClients = [];
  List<dynamic> _certifications = [];
  List<dynamic> _interests = [];
  List<dynamic> _specialties = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await getCurrentUserData();
    setState(() {
      _firstName = userData['firstName'];
      _lastName = userData['lastName'];
      _contactNumber = userData['profileDetails']['contactNumber'];
      _email = userData['email'];
      _address = userData['profileDetails']['address'];
      _profileImageURL = userData['profileImageURL'];
      _currentClients = userData['currentClients'];
      _certifications = userData['profileDetails']['certifications'];
      _interests = userData['profileDetails']['interests'];
      _specialties = userData['profileDetails']['specialty'];
      _isLoading = false;
    });
  }

  void _goToEditTrainerProfileScreen() {
    Navigator.of(context).pushNamed('/editTrainerProfile');
  }

  void _goToTrainerScheduleScreen() {
    Navigator.of(context).pushNamed('/trainerSchedule');
  }

  void _goToTrainerCurrentClientsScreen() {
    Navigator.of(context).pushNamed('/trainerCurrentClients');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => displayQuitDialogue(context),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: homeAppBar(context,
                title: _profileInfoHeader(), onRefresh: () => _fetchUserData()),
            body: switchedLoadingContainer(
                _isLoading,
                homeBackgroundContainer(context,
                    child: SafeArea(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _profileImage(),
                        SizedBox(height: 25),
                        _diagonalDataContent(),
                        _homeRowContainers(),
                        _trainerDetailsTabs()
                      ],
                    ))))),
      ),
    );
  }

  Widget _profileInfoHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      //SizedBox(width: MediaQuery.of(context).size.width * 0.1),
      Column(children: [
        futuraText('$_firstName $_lastName', textStyle: blackBoldStyle()),
        futuraText(
            '${_currentClients.length} Client${_currentClients.length != 1 ? 's' : ''}',
            textStyle: blackBoldStyle(size: 15))
      ])
    ]);
  }

  Widget _profileImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: buildProfileImage(profileImageURL: _profileImageURL, radius: 50),
    );
  }

  Widget _diagonalDataContent() {
    return Column(children: [
      Container(
        height: 20,
        width: 200,
        child: futuraText(_email, textStyle: blackBoldStyle(size: 15)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: futuraText(_contactNumber, textStyle: blackBoldStyle(size: 15)),
      ),
      futuraText(_address.isNotEmpty ? _address : 'NO ADDRESS',
          textStyle: whiteBoldStyle(size: 15))
    ]);
  }

  Widget _homeRowContainers() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(children: [
                  homeRowContainer(
                      iconPath: 'assets/images/icons/view_my_clients.png',
                      label: 'View My Clients',
                      onPress: () => _goToTrainerCurrentClientsScreen()),
                  homeRowContainer(
                      iconPath: 'assets/images/icons/view_my_schedule.png',
                      label: 'View My Schedule',
                      onPress: () => _goToTrainerScheduleScreen()),
                  homeRowContainer(
                      iconPath: 'assets/images/icons/profile_description.png',
                      label: 'Profile Description',
                      onPress: () => _goToEditTrainerProfileScreen()),
                ]))));
  }

  Widget _trainerDetailsTabs() {
    return Column(children: [
      SizedBox(
        child: TabBar(tabs: [
          Tab(
              child: futuraText('CERTIFICATIONS',
                  textStyle: blackBoldStyle(size: 12))),
          Tab(
              child:
                  futuraText('INTERESTS', textStyle: blackBoldStyle(size: 15))),
          Tab(
              child: futuraText('TRAINING SPECIALTY',
                  textStyle: blackBoldStyle(size: 14)))
        ]),
      ),
      SizedBox(
        height: 200,
        child: TabBarView(children: [
          _trainerCertifications(),
          _trainerInterests(),
          _trainerSpecialty()
        ]),
      )
    ]);
  }

  Widget _trainerCertifications() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Container(
              height: 80,
              width: double.infinity,
              color: CustomColors.love,
            ),
          ),
          if (_certifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: SizedBox(
                height: 130,
                child: Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _certifications.length,
                      itemBuilder: (context, index) {
                        if (index % 2 == 0) {
                          return sunGradientBox(label: _certifications[index]);
                        } else {
                          return moonGradientBox(label: _certifications[index]);
                        }
                      }),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _trainerInterests() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Container(
              height: 80,
              width: double.infinity,
              color: CustomColors.love,
            ),
          ),
          if (_interests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: SizedBox(
                height: 130,
                child: Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _interests.length,
                      itemBuilder: (context, index) {
                        if (index % 2 == 0) {
                          return sunGradientBox(label: _interests[index]);
                        } else {
                          return moonGradientBox(label: _interests[index]);
                        }
                      }),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _trainerSpecialty() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Container(
              height: 80,
              width: double.infinity,
              color: CustomColors.love,
            ),
          ),
          if (_specialties.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: SizedBox(
                height: 130,
                child: Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialties.length,
                      itemBuilder: (context, index) {
                        if (index % 2 == 0) {
                          return sunGradientBox(label: _specialties[index]);
                        } else {
                          return moonGradientBox(label: _specialties[index]);
                        }
                      }),
                ),
              ),
            )
        ],
      ),
    );
  }
}
