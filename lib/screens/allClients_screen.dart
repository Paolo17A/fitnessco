import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/UserOverview_widget.dart';

class AllClientsScreen extends StatefulWidget {
  const AllClientsScreen({super.key});

  @override
  AllClientsScreenState createState() => AllClientsScreenState();
}

class AllClientsScreenState extends State<AllClientsScreen> {
  Future<List<QueryDocumentSnapshot>> getUsers() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    final QuerySnapshot trainersSnapshot =
        await usersCollection.where('accountType', isEqualTo: 'CLIENT').get();
    return trainersSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All CLIENTS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: getUsers(),
          builder: (BuildContext context,
              AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<QueryDocumentSnapshot> users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return UserOverview(
                    firstName: users[index]['firstName'],
                    lastName: users[index]['lastName'],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
