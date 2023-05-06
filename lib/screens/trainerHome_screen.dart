// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/signin_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  final double _buttonWidth = 250;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.purpleAccent.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.red,
                    ),
                    Column(
                      children: const [
                        SizedBox(height: 15),
                        Text(
                          "username",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Total Revenue: 69420",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      squareIconButton_Widget(
                          context, 'View My Clients', Icons.people,
                          buttonWidth: _buttonWidth),
                      squareIconButton_Widget(
                          context, 'View My Schedule', Icons.calendar_month,
                          buttonWidth: _buttonWidth),
                      squareIconButton_Widget(
                          context, 'Edit Profile', Icons.edit,
                          buttonWidth: _buttonWidth),
                      squareIconButton_Widget(
                          context, 'Settings', Icons.settings,
                          buttonWidth: _buttonWidth),
                      LogOutWidget(screenSize: screenSize)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
