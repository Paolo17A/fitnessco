import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/widgets/client_request_card_widget.dart';
import 'package:flutter/material.dart';

class ClientRequestsContainer extends StatefulWidget {
  final VoidCallback refreshParent;
  const ClientRequestsContainer({super.key, required this.refreshParent});

  @override
  State<ClientRequestsContainer> createState() =>
      ClientRequestsContainerState();
}

class ClientRequestsContainerState extends State<ClientRequestsContainer> {
  bool _isLoading = true;
  List<String> _requestedClients = [];
  List<QueryDocumentSnapshot> _clientSnapshots = [];

  @override
  initState() {
    super.initState();
    getAllClientRequests();
  }

  void getAllClientRequests() async {
    try {
      String? currentUID = FirebaseAuth.instance.currentUser?.uid;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .get();
      final userData = docSnapshot.data();
      if (userData != null && userData.containsKey('trainingRequests')) {
        _requestedClients = List<String>.from(userData['trainingRequests']);
      }
      if (_requestedClients.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fetch documents with UIDs in _requestedClients list
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: _requestedClients)
            .get();

        setState(() {
          _clientSnapshots = querySnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting client requests: $error')));
    }
  }

  void _approveRequest(BuildContext context, String clientUID) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(clientUID)
          .update({'isConfirmed': true});

      // Remove clientUID from current user's trainingRequests array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'trainingRequests': FieldValue.arrayRemove([clientUID]),
      });

      // Add clientUID to current user's currentUsers array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'currentClients': FieldValue.arrayUnion([clientUID]),
      });
      widget.refreshParent();
      //_getAllClientRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error approving training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _denyRequest(BuildContext context, String clientUID) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(clientUID)
          .update({'currentTrainer': ''});

      // Remove clientUID from current user's trainingRequests array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'trainingRequests': FieldValue.arrayRemove([clientUID]),
      });

      getAllClientRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error denying training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (_requestedClients.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No Client Requests',
              style: _thisTextStyle(),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 250,
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _clientSnapshots.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot documentSnapshot =
                    _clientSnapshots[index];
                String firstName = documentSnapshot['firstName'];
                String lastName = documentSnapshot['lastName'];

                return ClientRequestCard(
                  clientUID: _clientSnapshots[index].id,
                  firstName: firstName,
                  lastName: lastName,
                  approveReq: () =>
                      _approveRequest(context, _clientSnapshots[index].id),
                  denyReq: () =>
                      _denyRequest(context, _clientSnapshots[index].id),
                );
              },
            ),
          ),
        );
      }
    }
  }
}

TextStyle _thisTextStyle() {
  return const TextStyle(
      fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500);
}
