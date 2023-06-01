// ignore_for_file: file_names

import 'package:fitnessco/screens/selectedClientProfile_screen.dart';
import 'package:fitnessco/screens/selectedTrainerProfile_screen.dart';
import 'package:flutter/material.dart';

class UserOverview extends StatelessWidget {
  final String uid;
  final String accountType;
  final String firstName;
  final String lastName;
  final bool isBeingViewedByAdmin;

  const UserOverview(
      {Key? key,
      required this.uid,
      required this.accountType,
      required this.firstName,
      required this.lastName,
      required this.isBeingViewedByAdmin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purpleAccent.withOpacity(0.3),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.amber,
        ),
        title: Text("$firstName $lastName"),
        trailing: ElevatedButton(
          child: const Text("View Profile"),
          onPressed: () {
            if (accountType == "TRAINER") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectedTrainerProfile(
                          uid: uid,
                          isBeingViewedByAdmin: isBeingViewedByAdmin,
                        )),
              );
            } else if (accountType == "CLIENT") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectedClientProfile(uid: uid)),
              );
            }
            // Navigate to user profile screen
          },
        ),
      ),
    );
  }
}
