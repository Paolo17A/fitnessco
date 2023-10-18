import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/client_request_card_widget.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllClientRequests();
  }

  void getAllClientRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      //  Get the current trainer's user data
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (docSnapshot.data() == null ||
          !docSnapshot.data()!.containsKey('trainingRequests')) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Error getting training requests')));
        return;
      }
      _requestedClients =
          List<String>.from(docSnapshot.data()!['trainingRequests']);

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
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      setState(() {
        _isLoading = true;
      });

      //  Get the current trainer's user data
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      //  Once we get the current trainer's user data, we check if the selected client's UID is still in the trainer's trainingRequests list
      List<String> currentRequestingClients =
          List<String>.from(currentUserDoc.data()!['trainingRequests']);
      if (!currentRequestingClients.contains(clientUID)) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('This training request is no longer available')));
        setState(() {
          _isLoading = true;
          getAllClientRequests();
        });
        return;
      }

      //  If the selected client is still in the trainer's trainingRequests list, then we will proceed to approving the request
      await updateThisUserData(clientUID, {'isConfirmed': true});

      // Remove clientUID from current trainer's trainingRequests array and add it to the currentClients array
      await updateThisUserData(FirebaseAuth.instance.currentUser!.uid, {
        'trainingRequests': FieldValue.arrayRemove([clientUID]),
        'currentClients': FieldValue.arrayUnion([clientUID]),
      });

      widget.refreshParent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error approving training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _denyRequest(BuildContext context, String clientUID) async {
    final scaffoldMesseger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      //  Check if the client is still in the current trainer's list of training requests
      final currentUserDoc =
          await getThisUserData(FirebaseAuth.instance.currentUser!.uid);

      //  Once we get the current trainer's user data, we check if the selected client's UID is still in the trainer's trainingRequests list
      List<String> currentRequestingClients =
          List<String>.from(currentUserDoc.data()!['trainingRequests']);
      if (!currentRequestingClients.contains(clientUID)) {
        scaffoldMesseger.showSnackBar(const SnackBar(
            content: Text('This training request is no longer available')));
        setState(() {
          _isLoading = true;
          getAllClientRequests();
        });
        return;
      }

      //  Set the currentTrainer of the client to empty
      await updateThisUserData(clientUID, {'currentTrainer': ''});

      // Remove clientUID from current user's trainingRequests array
      await updateThisUserData(FirebaseAuth.instance.currentUser!.uid, {
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
    return switchedLoadingContainer(
        _isLoading,
        Column(children: [
          Text(
            'Client Requests',
            textAlign: TextAlign.left,
            style: greyBoldStyle(size: 18),
          ),
          Divider(thickness: 1.5),
          roundedContainer(
              height: MediaQuery.of(context).size.height * 0.15,
              child: _requestedClients.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _clientSnapshots.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot documentSnapshot =
                            _clientSnapshots[index];
                        String firstName = documentSnapshot['firstName'];
                        String lastName = documentSnapshot['lastName'];
                        String profileImageURL =
                            documentSnapshot['profileImageURL'];
                        return ClientRequestCard(
                          clientUID: _clientSnapshots[index].id,
                          firstName: firstName,
                          lastName: lastName,
                          profileImageURL: profileImageURL,
                          approveReq: () => _approveRequest(
                              context, _clientSnapshots[index].id),
                          denyReq: () =>
                              _denyRequest(context, _clientSnapshots[index].id),
                        );
                      },
                    )
                  : Center(
                      child: futuraText('No Client Requests',
                          textStyle: blackBoldStyle()),
                    )),
          Divider(thickness: 1.5)
        ]));
  }
}
