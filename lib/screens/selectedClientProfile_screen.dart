// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/widgets/MembershipStatusDropdown_widget.dart';
import 'package:fitnessco/widgets/gym_history_entry_widget.dart';
import 'package:fitnessco/widgets/payment_interval_dropdown_widget.dart';
import 'package:flutter/material.dart';

class SelectedClientProfile extends StatefulWidget {
  final String uid;

  const SelectedClientProfile({Key? key, required this.uid}) : super(key: key);

  @override
  _SelectedClientProfileState createState() => _SelectedClientProfileState();
}

class _SelectedClientProfileState extends State<SelectedClientProfile> {
  String _selectedMembershipStatus = 'UNPAID';
  String _selectedPaymentInterval = 'DAILY';
  bool _currentlyUsingGym = false;
  List<dynamic> gymHistory = [];
  String _profileImageURL = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
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

        if (!userData.containsKey('paymentInterval')) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .update({'paymentInterval': 'DAILY'});
          _selectedPaymentInterval = 'DAILY';
        } else {
          _selectedPaymentInterval = userData['paymentInterval'] as String;
        }

        gymHistory = userData['gymHistory'];
        _profileImageURL = userData['profileImageURL'] as String;
        if (gymHistory.isNotEmpty) {
          _currentlyUsingGym = (gymHistory[gymHistory.length - 1]['timeOut']
                      as Map<dynamic, dynamic>)
                  .isEmpty
              ? true
              : false;
        }
      });
    }
  }

  void _saveMembershipStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
        'membershipStatus': _selectedMembershipStatus,
        'paymentInterval': _selectedPaymentInterval
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Client Profile Saved Successfully"),
        backgroundColor: Colors.purple,
      ));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $error"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  //  TIMING IN/OUT
  //========================================================================================================================
  void _timeInClient() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'gymHistory': gymHistory});

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully timed user in')));
      setState(() {
        _currentlyUsingGym = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error timing in: ${error.toString()}')));
    }
  }

  void _timeOutClient() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      gymHistory[gymHistory.length - 1]['timeOut'] = {
        'month': DateTime.now().month,
        'year': DateTime.now().year,
        'day': DateTime.now().day,
        'hour': DateTime.now().hour,
        'minute': DateTime.now().minute,
        'second': DateTime.now().second
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'gymHistory': gymHistory});

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully timed user out')));
      setState(() {
        _currentlyUsingGym = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error timing in: ${error.toString()}')));
    }
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
//========================================================================================================================

  @override
  Widget build(BuildContext context) {
    CollectionReference trainers =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
        appBar: AppBar(
          title: FutureBuilder<DocumentSnapshot>(
            future: trainers.doc(widget.uid).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  var trainerData =
                      snapshot.data!.data() as Map<String, dynamic>;
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
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  var trainerData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            color: Colors.purpleAccent.withOpacity(0.1),
                            child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.04),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildProfileImage(),
                                      Column(children: [
                                        const SizedBox(height: 15),
                                        Text(
                                            '${trainerData['firstName']} ${trainerData['lastName']}',
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 15),
                                        Text(
                                            "Membership Status: $_selectedMembershipStatus",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        const SizedBox(height: 20)
                                      ])
                                    ]))),
                        const SizedBox(height: 20),
                        MembershipStatusDropdown(
                            selectedMembershipStatus: _selectedMembershipStatus,
                            onChanged: (String? newValue) {
                              _selectedMembershipStatus = newValue!;
                            }),
                        const SizedBox(height: 20),
                        PaymentIntervalDropdownWidget(
                            selectedPaymentInterval: _selectedPaymentInterval,
                            onChanged: (String? newValue) {
                              _selectedPaymentInterval = newValue!;
                            }),
                        ElevatedButton(
                            onPressed: _saveMembershipStatus,
                            child: const Text(
                              'SAVE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Gym Usage History',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _currentlyUsingGym
                                            ? _timeOutClient()
                                            : _timeInClient();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple
                                              .withOpacity(0.6)),
                                      child: Text(
                                        _currentlyUsingGym
                                            ? 'TIME OUT'
                                            : 'TIME IN',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: gymHistory.length,
                                      itemBuilder: (context, index) {
                                        return gymHistoryEntryWidget(
                                            gymHistory[index]['timeIn'],
                                            gymHistory[index]['timeOut']);
                                      })
                                ])))
                      ]);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
