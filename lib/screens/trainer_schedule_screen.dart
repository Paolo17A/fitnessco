import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerScheduleScreen extends StatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> userDataList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getAllClientAppointments();
  }

  void _getAllClientAppointments() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final trainerData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      List<dynamic> clientUIDs = trainerData.data()!['currentClients'];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: clientUIDs)
          .get();

      for (var snapshot in querySnapshot.docs) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          // Extract the UID from the snapshot's reference
          String uid = snapshot.reference.id;
          if ((data['appointment'] as Map<dynamic, dynamic>).isNotEmpty) {
            userDataList.add({
              'uid': uid,
              'name': '${data['firstName']} ${data['lastName']}',
              'appointment': data['appointment'] ?? {},
            });
          }
        }
      }

      print(userDataList);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content:
              Text('Error getting client appointments: ${error.toString()}')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Current Schedule"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                  child: userDataList.isEmpty
                      ? const Text(
                          'You have no upcoming appointments',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 30),
                        )
                      : Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: userDataList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.deepPurple
                                              .withOpacity(0.5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                userDataList[index]['name'],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  dateMapToString(
                                                      userDataList[index]
                                                          ['appointment']),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                        )),
                                  );
                                }),
                          ],
                        ))),
    );
  }

  String dateMapToString(Map<dynamic, dynamic> time) {
    int year = time['year'];
    int month = time['month'];
    int day = time['day'];
    int hour = time['hour'];
    int minute = time['minute'];

    String period = (hour < 12) ? 'AM' : 'PM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    String formattedDateTime =
        '$year-${_twoDigits(month)}-${_twoDigits(day)} ${_twoDigits(hour)}:${_twoDigits(minute)} $period';
    return formattedDateTime;
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }
}
