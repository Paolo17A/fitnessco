import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/color_utils.dart';
import '../widgets/app_bar_widgets.dart';
import 'selected_client_profile_screen.dart';

class AllClientsScreen extends StatefulWidget {
  const AllClientsScreen({super.key});

  @override
  AllClientsScreenState createState() => AllClientsScreenState();
}

class AllClientsScreenState extends State<AllClientsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allClients = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllClients();
  }

  Future getAllClients() async {
    try {
      final clients = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'CLIENT')
          .get();
      allClients = clients.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      showErrorMessage(context, label: 'Error getting all Clients: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: largeGradientAppBar('All Clients'),
        body: switchedLoadingContainer(
            _isLoading,
            viewTrainerBackgroundContainer(context,
                child: _allClientsContainer())));
  }

  Widget _allClientsContainer() {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: allClients.isNotEmpty
                ? ListView.builder(
                    itemCount: allClients.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _clientContainer(allClients[index]);
                    },
                  )
                : Center(
                    child: Text(
                      'NO CLIENTS AVAILABLE',
                      style: TextStyle(
                          fontSize: 35,
                          color: CustomColors.purpleSnail,
                          fontWeight: FontWeight.bold),
                    ),
                  )));
  }

  Widget _clientContainer(DocumentSnapshot trainerDocument) {
    final trainerData = trainerDocument.data() as Map<dynamic, dynamic>;
    String profileImageURL = trainerData['profileImageURL'];
    String firstName = trainerData['firstName'];
    String lastName = trainerData['lastName'];
    String sex = trainerData['profileDetails']['sex'];
    num age = trainerData['profileDetails']['age'];
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: ((context) =>
                SelectedClientProfile(clientUID: trainerDocument.id))),
      ),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      clientProfileImage(profileImageURL),
                      clientProfileContent(
                          context, firstName, lastName, sex, age)
                    ]),
                userDivider()
              ])),
    );
  }
}
