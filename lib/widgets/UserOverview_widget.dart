// ignore_for_file: file_names

import 'package:fitnessco/screens/selectedClientProfile_screen.dart';
import 'package:flutter/material.dart';

class UserOverview extends StatelessWidget {
  final String uid;
  final String accountType;
  final String firstName;
  final String lastName;
  final bool isBeingViewedByAdmin;
  final String profileImageurL;

  const UserOverview(
      {Key? key,
      required this.uid,
      required this.accountType,
      required this.firstName,
      required this.lastName,
      required this.isBeingViewedByAdmin,
      this.profileImageurL = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.purpleAccent.withOpacity(0.3),
        child: ListTile(
            leading: profileImageurL.isEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white))
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple,
                    backgroundImage: NetworkImage(profileImageurL)),
            title: Text("$firstName $lastName"),
            trailing: ElevatedButton(
                child: const Text("View Profile"),
                onPressed: () {
                  if (accountType == "TRAINER") {
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectedTrainerProfile(trainerDoc: uid)));*/
                  } else if (accountType == "CLIENT") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SelectedClientProfile(uid: uid)),
                    );
                  }
                  // Navigate to user profile screen
                })));
  }
}
