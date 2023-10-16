// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/all_trainers_screen.dart';
import 'package:fitnessco/screens/client_home_screen.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:flutter/material.dart';

class SelectedTrainerProfile extends StatefulWidget {
  final String uid;
  final bool isBeingViewedByAdmin;

  const SelectedTrainerProfile({
    Key? key,
    required this.uid,
    required this.isBeingViewedByAdmin,
  }) : super(key: key);

  @override
  _SelectedTrainerProfileState createState() => _SelectedTrainerProfileState();
}

class _SelectedTrainerProfileState extends State<SelectedTrainerProfile> {
  bool isTrainingRequestSent = false;
  bool isViewingCurrentTrainer = false;
  String _profileImageURL = '';
  //late String currentUserUID;

  @override
  void initState() {
    super.initState();
    if (!widget.isBeingViewedByAdmin) {
      _checkTrainingRequestStatus();
    }
  }

  void _checkTrainingRequestStatus() {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        String currentTrainerUID = userData['currentTrainer'];
        if (widget.uid == currentTrainerUID) {
          isViewingCurrentTrainer = true;
          isTrainingRequestSent = true;
        } else {
          isViewingCurrentTrainer = false;
          if (currentTrainerUID == '') {
            isTrainingRequestSent = false;
          } else {
            isTrainingRequestSent = true;
          }
        }
        _profileImageURL = userData['profileImageURL'] as String;
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $error"),
        backgroundColor: Colors.purple,
      ));
      Navigator.pop(context);
    });
  }

  void _deleteTrainer(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'isDeleted': true}).then((value) {
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $error"),
        backgroundColor: Colors.purple,
      ));
    });
  }

  void _sendTrainerRequest(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigatorState = Navigator.of(context);

    final trainerData = await getThisUserData(widget.uid);

    if (trainerData.data()!['isConfirmed'] == true) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'This training request has already been accepted by the trainer')));
      navigatorState.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const AllTrainersScreen(
                    isBeingViewedByAdmin: false,
                  )),
          (Route<dynamic> route) => false);
      return;
    } else if (trainerData.data()!['isDeleted'] == true) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('This trainer has been deleted by the admin')));
      navigatorState.pop();
      return;
    }

    /*  These lines of code first update the trainingRequests array of the trainer's data by adding a new entry to the list.
    Next, we update the update inside the client's data; namely the currentTrainer parameter and the isConfirmed parameter.
    We assign a current trainer but set isConfirmed to be false because the trainer must then confirm the request on their end.*/
    FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'trainingRequests':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    }).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'currentTrainer': widget.uid,
        'isConfirmed': false,
      }).then((value) {
        setState(() {
          isTrainingRequestSent = true;
          isViewingCurrentTrainer = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Training request sent"),
        ));
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error sending training request: $error"),
          backgroundColor: Colors.purple,
        ));
      });
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending training request: $error"),
        backgroundColor: Colors.purple,
      ));
    });
  }

  void _cancelTrainerRequest(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigatorState = Navigator.of(context);

    //  Get the current user data from Firebase first. Don't use the .then() callback because return statements don't work in there.
    final currentUserDoc =
        await getThisUserData(FirebaseAuth.instance.currentUser!.uid);

    if (currentUserDoc.data()!['isConfirmed'] == true) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'This training request has already been accepted by the trainer')));
      navigatorState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
          (Route<dynamic> route) => false);
      return;
    }

    //  Upon cancellation, we will first remove the client UID from the trainer's trainingRequests list in Firebase
    FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'trainingRequests':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    }).then((value) {
      // After removing the client UID from the trainingRequests list, we will set the client's trainer parameters back to its default empty values
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'currentTrainer': '',
        'isConfirmed': false,
      }).then((value) {
        //  No training request has been sent and there is no more current trainer. We must refresh the build to display the update values in the visuals
        setState(() {
          isTrainingRequestSent = false;
          isViewingCurrentTrainer = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Training request canceled"),
        ));
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error canceling training request: $error"),
          backgroundColor: Colors.purple,
        ));
      });
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error canceling training request: $error"),
        backgroundColor: Colors.purple,
      ));
    });
  }

  Widget _buildProfileImage() {
    if (_profileImageURL != '') {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_profileImageURL),
      );
    } else {
      return const CircleAvatar(radius: 50, child: Icon(Icons.person));
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference trainers =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: trainers.doc(widget.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                var trainerData = snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                    '${trainerData['firstName']} ${trainerData['lastName']}');
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: trainers.doc(widget.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var trainerData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProfileImage(),
                          Column(
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                'Name: ${trainerData['firstName']} ${trainerData['lastName']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'ID Number: ${trainerData['idNumber']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  if (widget.isBeingViewedByAdmin)
                    ElevatedButton.icon(
                      onPressed: () => _deleteTrainer(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Trainer'),
                    )
                  else if (!isTrainingRequestSent)
                    ElevatedButton.icon(
                      onPressed: () => _sendTrainerRequest(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Send Training Request'),
                    )
                  else if (isViewingCurrentTrainer)
                    ElevatedButton.icon(
                      onPressed: () => _cancelTrainerRequest(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Training Request'),
                    )
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
