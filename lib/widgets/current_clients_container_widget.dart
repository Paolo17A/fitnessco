import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/current_client_card_widget.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
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
      final userData = await getCurrentUserData();
      _currentClients = List<String>.from(userData['currentClients']);

      if (_currentClients.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fetch documents with UIDs in _requestedClients list
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: _currentClients)
            .get();

        setState(() {
          _clientSnapshots = querySnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (error) {
      showErrorMessage(context,
          label: "Error getting current client requests: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/trainerHome');
        return true;
      },
      child: switchedLoadingContainer(
          _isLoading,
          roundedContainer(
              color: CustomColors.love,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(children: [
                _currentClientsHeader(),
                _currentClientsContainer()
              ]))),
    );
  }

  Widget _currentClientsHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: futuraText('CURRENT CLIENTS', textStyle: greyBoldStyle(size: 18)),
    );
  }

  Widget _currentClientsContainer() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: roundedContainer(
            color: Colors.white.withOpacity(0.75),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.37,
              child: _currentClients.isNotEmpty
                  ? _currentClientEntries()
                  : Center(
                      child: futuraText('No Current Clients',
                          textStyle: greyBoldStyle(size: 15))),
            )));
  }

  Widget _currentClientEntries() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _clientSnapshots.length,
            itemBuilder: (context, index) {
              final documentSnapshot = _clientSnapshots[index];
              String firstName = documentSnapshot['firstName'];
              String lastName = documentSnapshot['lastName'];
              String profileImageURL = documentSnapshot['profileImageURL'];

              return CurrentClientCard(
                  clientUID: _clientSnapshots[index].id,
                  firstName: firstName,
                  lastName: lastName,
                  isClient: false,
                  profileImageURL: profileImageURL);
            }));
  }
}
