import 'package:fitnessco/screens/selected_trainer_profile_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllTrainersScreen extends StatefulWidget {
  const AllTrainersScreen({super.key});

  @override
  AllTrainersScreenState createState() => AllTrainersScreenState();
}

class AllTrainersScreenState extends State<AllTrainersScreen> {
  bool _isLoading = true;
  bool isBeingViewedByAdmin = false;
  List<DocumentSnapshot> allTrainers = [];

  @override
  void initState() {
    super.initState();
    initializeAllTrainersScreen();
  }

  Future initializeAllTrainersScreen() async {
    try {
      final userData = await getCurrentUserData();
      isBeingViewedByAdmin = await userData['accountType'] == 'ADMIN';

      final trainers = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'TRAINER')
          .where('isDeleted', isEqualTo: false)
          .get();
      allTrainers = trainers.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error getting all trainers: $error');
    }
  }

  void _goToAddTrainersScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/addTrainer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _allTrainersAppBar(),
      body: switchedLoadingContainer(
        _isLoading,
        viewTrainerBackgroundContainer(context, child: _allTrainersContainer()),
      ),
    );
  }

  AppBar _allTrainersAppBar() {
    return AppBar(
      toolbarHeight: 85,
      flexibleSpace: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [CustomColors.jigglypuff, CustomColors.love])),
      ),
      title: Center(
          child: Text('All Trainers',
              style: TextStyle(fontWeight: FontWeight.bold))),
      actions: isBeingViewedByAdmin
          ? [
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _goToAddTrainersScreen(context))
            ]
          : null,
    );
  }

  Widget _allTrainersContainer() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: allTrainers.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: allTrainers.length,
              itemBuilder: ((context, index) {
                return _trainerContainer(allTrainers[index]);
              }))
          : Center(
              child: Text(
              'NO TRAINERS AVAILABLE',
              style: TextStyle(
                  fontSize: 35,
                  color: CustomColors.purpleSnail,
                  fontWeight: FontWeight.bold),
            )),
    ));
  }

  Widget _trainerContainer(DocumentSnapshot trainerDocument) {
    final trainerData = trainerDocument.data() as Map<dynamic, dynamic>;
    String profileImageURL = trainerData['profileImageURL'];
    String firstName = trainerData['firstName'];
    String lastName = trainerData['lastName'];
    List<dynamic> currentClients = trainerData['currentClients'];
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  SelectedTrainerProfile(trainerDoc: trainerDocument)));
        },
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        trainerProfileImage(profileImageURL),
                        trainerProfileContent(
                            context, firstName, lastName, currentClients)
                      ]),
                  userDivider()
                ])));
  }
}
