import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/widgets/current_client_card_widget.dart';
import 'package:flutter/material.dart';

class CurrentClientContainer extends StatefulWidget {
  const CurrentClientContainer({super.key});

  @override
  State<CurrentClientContainer> createState() => CurrentClientContainerState();
}

class CurrentClientContainerState extends State<CurrentClientContainer> {
  bool _isLoading = true;
  List<String> _currentClients = [];
  List<QueryDocumentSnapshot> _clientSnapshots = [];

  @override
  void initState() {
    super.initState();
    getAllCurrentClients();
  }

  void getAllCurrentClients() async {
    try {
      String? currentUID = FirebaseAuth.instance.currentUser?.uid;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .get();
      final userData = docSnapshot.data();
      if (userData != null && userData.containsKey('currentClients')) {
        _currentClients = List<String>.from(userData['currentClients']);
      }
      if (_currentClients.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fetch documents with UIDs in _requestedClients list
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: _currentClients)
            .get();

        setState(() {
          _clientSnapshots = querySnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error denying training request: $error"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (_currentClients.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No Current Clients',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 250,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _clientSnapshots.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot documentSnapshot = _clientSnapshots[index];
              String firstName = documentSnapshot['firstName'];
              String lastName = documentSnapshot['lastName'];

              return CurrentClientCard(
                clientUID: _clientSnapshots[index].id,
                firstName: firstName,
                lastName: lastName,
                isClient: false,
              );
            },
          ),
        );
      }
    }
  }
}
