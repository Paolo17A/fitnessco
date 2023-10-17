// ignore_for_file: file_names

import 'package:fitnessco/screens/add_trainer_screen.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/UserOverview_widget.dart';

class AllTrainersScreen extends StatefulWidget {
  const AllTrainersScreen({super.key});

  @override
  AllTrainersScreenState createState() => AllTrainersScreenState();
}

class AllTrainersScreenState extends State<AllTrainersScreen> {
  bool isBeingViewedByAdmin = false;
  late Stream<QuerySnapshot> _trainersStream;
  @override
  void initState() {
    super.initState();
    _trainersStream = FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'TRAINER')
        .where('isDeleted', isEqualTo: false)
        .snapshots();
    initializeAllTrainersScreen();
  }

  Future initializeAllTrainersScreen() async {
    final userData = await getCurrentUserData();
    isBeingViewedByAdmin = await userData['accountType'] == 'ADMIN';
  }

  void _goToAddTrainersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTrainerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Trainers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: isBeingViewedByAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _goToAddTrainersScreen(context);
                  },
                )
              ]
            : null,
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _trainersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<QueryDocumentSnapshot> users = snapshot.data!.docs;
            List<String> trainerUids = users.map((doc) => doc.id).toList();
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                return UserOverview(
                  uid: trainerUids[index],
                  accountType: users[index]['accountType'],
                  firstName: users[index]['firstName'],
                  lastName: users[index]['lastName'],
                  isBeingViewedByAdmin: isBeingViewedByAdmin,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
