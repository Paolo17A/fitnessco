// ignore_for_file: use_build_context_synchronously, file_names, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late String currentUserUID;

  @override
  void initState() {
    super.initState();
    if (!widget.isBeingViewedByAdmin) {
      _checkTrainingRequestStatus();
    }
  }

  void _checkTrainingRequestStatus() {
    currentUserUID = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    usersCollection.doc(currentUserUID).get().then((DocumentSnapshot snapshot) {
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
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'isDeleted': true});

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _sendTrainerRequest(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No current user logged in."),
        backgroundColor: Colors.purple,
      ));
      Navigator.pop(context);
      return;
    }

    currentUserUID = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'trainingRequests': FieldValue.arrayUnion([currentUserUID])
      });

      // Update currentTrainer field for the current user
      await usersCollection.doc(currentUserUID).update({
        'currentTrainer': widget.uid,
        'isConfirmed': false,
      });

      setState(() {
        isTrainingRequestSent = true;
        isViewingCurrentTrainer = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Training request sent"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _cancelTrainerRequest(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No current user logged in."),
        backgroundColor: Colors.purple,
      ));
      Navigator.pop(context);
      return;
    }

    currentUserUID = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'trainingRequests': FieldValue.arrayRemove([currentUserUID])
      });

      // Update currentTrainer field for the current user
      await usersCollection.doc(currentUserUID).update({
        'currentTrainer': '',
        'isConfirmed': false,
      });

      setState(() {
        isTrainingRequestSent = false;
        isViewingCurrentTrainer = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Training request canceled"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error canceling training request: $e"),
        backgroundColor: Colors.purple,
      ));
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
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.red,
                          ),
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
