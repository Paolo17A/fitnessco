// ignore_for_file: file_names

import 'package:fitnessco/screens/allClients_screen.dart';
import 'package:fitnessco/screens/manageGym_screen.dart';
import 'package:fitnessco/widgets/LogOut_Widget.dart';
import 'package:flutter/material.dart';
import '../widgets/SquareIconButton_widget.dart';
import 'allTrainers_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _goToAllTrainersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllTrainersScreen(
          isBeingViewedByAdmin: true,
        ),
      ),
    );
  }

  void _goToAllClientsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllClientsScreen(),
      ),
    );
  }

  void _goToManageGymScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ManageGymScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.purpleAccent.withOpacity(0.3),
            child: const Center(
                child: Text("FITNESSCO ADMIN PANEL",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ))),
          ),
          Expanded(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    squareIconButton_Widget(
                        context,
                        'View All Trainers',
                        Icons.directions_run,
                        buttonWidth: 300,
                        () => _goToAllTrainersScreen(context)),
                    squareIconButton_Widget(
                        context,
                        'View All Clients',
                        Icons.people,
                        buttonWidth: 300,
                        () => _goToAllClientsScreen(context)),
                    squareIconButton_Widget(
                        context,
                        'Manage Gym',
                        Icons.fitness_center,
                        buttonWidth: 300,
                        () => _goToManageGymScreen(context)),
                    LogOutWidget(screenSize: screenSize)
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
