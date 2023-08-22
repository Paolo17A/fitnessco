import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/add_bmi_entry_screen.dart';
import 'package:flutter/material.dart';

class BMIHistoryScreen extends StatefulWidget {
  const BMIHistoryScreen({super.key});

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  bool _isLoading = true;
  bool _isError = false;
  List<dynamic> bmiHistory = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getBMIHistory();
  }

  void _getBMIHistory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  First we get the current client's data from Firebase
      final currentUserData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      //  if there is no BMI History parameter, we manually add it on the fly
      if (!currentUserData.data()!.containsKey('bmiHistory')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'bmiHistory': []});
      } else {
        var tempList = currentUserData.data()!['bmiHistory'] as List<dynamic>;
        bmiHistory = List.from(tempList.reversed);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting BMI History: ${error.toString()}')));
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BMI History'),
          actions: [
            IconButton(
                onPressed: () {
                  if (!_isLoading) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddBMIEntryScreen(
                                currentBMIEntries: bmiHistory)));
                  }
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isError
                ? const Center(
                    child: Text(
                    'ERROR GETTING BMI HISTORY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ))
                : Padding(
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: bmiHistory.isEmpty
                          ? const Text(
                              'You have no BMI entries yet',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            )
                          : Column(
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: bmiHistory.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurple
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.all(9),
                                              child: Text(
                                                '${(bmiHistory[index]['dateTime']['month']).toString()} - ${(bmiHistory[index]['dateTime']['day']).toString()} - ${(bmiHistory[index]['dateTime']['year']).toString()}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'BMI: ${bmiHistory[index]['bmiValue'].toString()}',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ]),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                    ),
                  ));
  }
}
