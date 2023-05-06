// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/widgets/LogOut_Widget.dart';

import '../screens/signin_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/SquareIconButton_widget.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
                //color: Colors.lightBlueAccent,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    squareIconButton_Widget(
                        context, 'View All Trainers', Icons.directions_run,
                        buttonWidth: 300),
                    squareIconButton_Widget(
                        context, 'View All Clients', Icons.people,
                        buttonWidth: 300),
                    squareIconButton_Widget(
                        context, 'Manage Gym', Icons.fitness_center,
                        buttonWidth: 300),
                    LogOutWidget(screenSize: screenSize)
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
