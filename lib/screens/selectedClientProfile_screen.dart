// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/widgets/MembershipStatusDropdown_widget.dart';
import 'package:flutter/material.dart';

class SelectedClientProfile extends StatefulWidget {
  final String uid;

  const SelectedClientProfile({Key? key, required this.uid}) : super(key: key);

  @override
  _SelectedClientProfileState createState() => _SelectedClientProfileState();
}

class _SelectedClientProfileState extends State<SelectedClientProfile> {
  String _selectedMembershipStatus = 'UNPAID';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    final userData = docSnapshot.data();
    if (userData != null) {
      setState(() {
        if (userData['membershipStatus'] == null) {
          _selectedMembershipStatus = 'UNPAID';
        } else {
          _selectedMembershipStatus = userData['membershipStatus'] as String;
        }
      });
    }
  }

  void _saveMembershipStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'membershipStatus': _selectedMembershipStatus});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Client Profile Saved Successfully"),
        backgroundColor: Colors.purple,
      ));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership statis: $error"),
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
                                '${trainerData['firstName']} ${trainerData['lastName']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Membership Status: $_selectedMembershipStatus",
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
                  const SizedBox(height: 20),
                  MembershipStatusDropdown(
                    selectedMembershipStatus: _selectedMembershipStatus,
                    onChanged: (String? newValue) {
                      _selectedMembershipStatus = newValue!;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveMembershipStatus,
                    child: const Text(
                      'SAVE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
