import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectedClientProfile extends StatelessWidget {
  final String uid;

  const SelectedClientProfile({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference trainers =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: trainers.doc(uid).get(),
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
        future: trainers.doc(uid).get(),
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
                              const Text(
                                "Membership Status: ",
                                style: TextStyle(
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
