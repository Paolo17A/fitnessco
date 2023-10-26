import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import 'chat_screen.dart';

class SelectedTrainerProfile extends StatefulWidget {
  final DocumentSnapshot trainerDoc;

  const SelectedTrainerProfile({
    Key? key,
    required this.trainerDoc,
  }) : super(key: key);

  @override
  _SelectedTrainerProfileState createState() => _SelectedTrainerProfileState();
}

class _SelectedTrainerProfileState extends State<SelectedTrainerProfile> {
  bool _isLoading = true;
  bool isBeingViewedByAdmin = false;
  Map<dynamic, dynamic> trainerData = {};

  //  CLIENT VIEWING TRAINER VARIABLES
  bool isTrainingRequestSent = false;
  bool isViewingCurrentTrainer = false;
  bool isConfirmed = false;

  @override
  void initState() {
    super.initState();
    trainerData = widget.trainerDoc.data() as Map<dynamic, dynamic>;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeSelectedTrainerScreen();
  }

  Future _initializeSelectedTrainerScreen() async {
    try {
      final currentUserData = await getCurrentUserData();
      isBeingViewedByAdmin = currentUserData['accountType'] == 'ADMIN';

      if (!isBeingViewedByAdmin) {
        _checkTrainingRequestStatus(currentUserData);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      showErrorMessage(context,
          label: 'error Initializing selected trainer screen: $error');
    }
  }

  void _checkTrainingRequestStatus(Map<dynamic, dynamic> currentUserData) {
    String currentTrainerUID = currentUserData['currentTrainer'];
    //  We are viewing our current trainer.
    if (widget.trainerDoc.id == currentTrainerUID) {
      isViewingCurrentTrainer = true;
      isTrainingRequestSent = true;
      if (currentUserData['isConfirmed'] == true) {
        isConfirmed = true;
      }
    }
    //  We are viewing another trainer (or we do not yet currently have an assigned trainer)
    else {
      isViewingCurrentTrainer = false;
      //  We don't have our own trainer yet
      if (currentTrainerUID == '') {
        isTrainingRequestSent = false;
      }
      //  This is our trainer. BUT the trainer has not yet accepted our training request.
      else {
        isTrainingRequestSent = true;
      }
    }
  }

  void _deleteTrainer(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await updateThisUserData(widget.trainerDoc.id, {'isDeleted': true});
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context,
          label: 'Error saving membership status: $error');
    }
  }

  void _sendTrainerRequest(BuildContext context) async {
    final trainerData = await getThisUserData(widget.trainerDoc.id);

    if (trainerData.data()!['isConfirmed'] == true) {
      showErrorMessage(context,
          label:
              'This training request has already been accepted by the trainer');
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
      return;
    } else if (trainerData.data()!['isDeleted'] == true) {
      showErrorMessage(context,
          label: 'This trainer has been deleted by the admin');
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
      return;
    }

    /*  These lines of code first update the trainingRequests array of the trainer's data by adding a new entry to the list.
    Next, we update the update inside the client's data; namely the currentTrainer parameter and the isConfirmed parameter.
    We assign a current trainer but set isConfirmed to be false because the trainer must then confirm the request on their end.*/
    await updateThisUserData(widget.trainerDoc.id, {
      'trainingRequests':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
    await updateCurrentUserData({
      'currentTrainer': widget.trainerDoc.id,
      'isConfirmed': false,
    });
    setState(() {
      isTrainingRequestSent = true;
      isViewingCurrentTrainer = true;
    });

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: CustomColors.jigglypuff,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  roundedContainer(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.6,
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: futuraText(
                              'Training request successfully sent.',
                              textStyle: TextStyle(
                                  color: CustomColors.purpleSnail,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30)),
                        ),
                      )),
                  gradientOvalButton(
                      label: 'CONTINUE',
                      onTap: () => Navigator.of(context).pop())
                ],
              ),
            ),
          );
        });
  }

  void _cancelTrainer() async {
    //  Upon cancellation, we will first remove the client UID from the trainer's trainingRequests list in Firebase
    await updateThisUserData(widget.trainerDoc.id, {
      'trainingRequests':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
    await updateCurrentUserData({
      'currentTrainer': '',
      'isConfirmed': false,
    });

    final messageThread = await FirebaseFirestore.instance
        .collection('messages')
        .where('trainerUID', isEqualTo: widget.trainerDoc.id)
        .where('clientUID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (messageThread.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageThread.docs[0].id)
          .delete();
    }
    setState(() {
      isTrainingRequestSent = false;
      isViewingCurrentTrainer = false;
    });
  }

  void _removeTrainer() async {
    //  Upon cancellation, we will first remove the client UID from the trainer's trainingRequests list in Firebase
    await updateThisUserData(widget.trainerDoc.id, {
      'currentClients':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
    await updateCurrentUserData({
      'currentTrainer': '',
      'isConfirmed': false,
    });

    final messageThread = await FirebaseFirestore.instance
        .collection('messages')
        .where('trainerUID', isEqualTo: widget.trainerDoc.id)
        .where('clientUID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (messageThread.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageThread.docs[0].id)
          .delete();
    }
    setState(() {
      isTrainingRequestSent = false;
      isViewingCurrentTrainer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
        return true;
      },
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _selectedTrainerAppBar(),
          body: switchedLoadingContainer(
              _isLoading,
              viewTrainerBackgroundContainer(context,
                  child: SafeArea(
                    child: Column(
                      children: [
                        _trainerTopHalf(),
                        _bottomHalf(),
                        if (isViewingCurrentTrainer && isConfirmed)
                          gradientOvalButton(
                              label: 'CHAT TRAINER',
                              width: 200,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              otherPersonUID:
                                                  widget.trainerDoc.id,
                                              isClient: !isBeingViewedByAdmin,
                                            )));
                              })
                      ],
                    ),
                  )))),
    );
  }

  AppBar _selectedTrainerAppBar() {
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
    );
  }

  Widget _trainerTopHalf() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(children: [
                    trainerProfileImage(trainerData['profileImageURL']),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Image.asset(
                                    'assets/images/icons/trainer_email.png',
                                    scale: 50),
                                futuraText(trainerData['email']),
                              ]),
                              Row(
                                children: [
                                  Image.asset(
                                      'assets/images/icons/trainer_contact.png',
                                      scale: 50),
                                  futuraText(trainerData['profileDetails']
                                      ['contactNumber']),
                                ],
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Row(children: [
                                    Image.asset(
                                        'assets/images/icons/trainer_address.png',
                                        scale: 50),
                                    futuraText(trainerData['profileDetails']
                                        ['address']),
                                  ]))
                            ]))
                  ]),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Column(children: [
                      trainerProfileContent(
                          context,
                          trainerData['firstName'],
                          trainerData['lastName'],
                          trainerData['currentClients']),
                      //ADMIN OPTIONS
                      if (isBeingViewedByAdmin)
                        ElevatedButton(
                          onPressed: () => _deleteTrainer(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Text('DELETE TRAINER'),
                        )
                      //  CLIENT OPTIONS
                      else if (!isTrainingRequestSent)
                        ElevatedButton(
                          onPressed: () => _sendTrainerRequest(context),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Text(
                            'SEND TRAINING REQUEST',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (isViewingCurrentTrainer && !isConfirmed)
                        Column(
                          children: [
                            roundedContainer(
                                color: CustomColors.purpleSnail,
                                child: Text('REQUEST PENDING')),
                            ElevatedButton(
                              onPressed: () => _cancelTrainer(),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: const Text('CANCEL REQUEST'),
                            ),
                          ],
                        )
                      else if (isViewingCurrentTrainer && isConfirmed)
                        ElevatedButton(
                          onPressed: () => _removeTrainer(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Text('REMOVE TRAINER'),
                        )
                    ]),
                  )
                ])),
        Divider(color: Colors.grey, thickness: 2)
      ],
    );
  }

  Widget _bottomHalf() {
    final certification =
        trainerData['profileDetails']['certifications'] as List<dynamic>;
    final interest =
        trainerData['profileDetails']['interests'] as List<dynamic>;
    final specialty =
        trainerData['profileDetails']['specialty'] as List<dynamic>;
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Column(
                  children: [
                    futuraText('CERTIFICATIONS', textStyle: blackBoldStyle()),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: certification
                            .map((cert) => futuraText(cert))
                            .toList())
                  ],
                ),
              ],
            )),
        Padding(
            padding: EdgeInsets.all(15),
            child: Row(children: [
              Column(children: [
                futuraText('INTERESTS', textStyle: blackBoldStyle()),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        interest.map((inter) => futuraText(inter)).toList())
              ])
            ])),
        Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Column(
                  children: [
                    futuraText('TRAINING SPECIALTY',
                        textStyle: blackBoldStyle()),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            specialty.map((spec) => futuraText(spec)).toList())
                  ],
                ),
              ],
            )),
        Divider(color: Colors.grey, thickness: 2)
      ],
    );
  }
}
