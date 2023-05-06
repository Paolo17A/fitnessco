// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/signin_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/LogOut_Widget.dart';
import '../widgets/SquareIconButton_widget.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double itemWidth = (screenSize.width - 60) / 2;
    final double itemHeight = itemWidth * 0.8;

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
                          "membershipStatus",
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
              child: GridView.count(
                padding: EdgeInsets.all(screenSize.width * 0.05),
                crossAxisCount: 2,
                crossAxisSpacing: screenSize.width * 0.05,
                mainAxisSpacing: screenSize.width * 0.05,
                childAspectRatio: itemWidth / itemHeight,
                children: [
                  squareIconButton_Widget(
                      context, 'View All Trainers', Icons.people),
                  squareIconButton_Widget(
                      context, 'View My Workout Plan', Icons.list),
                  squareIconButton_Widget(
                      context, 'My Training Session', Icons.fitness_center),
                  squareIconButton_Widget(
                      context, 'Workout History', Icons.history),
                  squareIconButton_Widget(context, 'Edit Profile', Icons.edit),
                  squareIconButton_Widget(context, 'Settings', Icons.settings),
                ],
              ),
            ),
            LogOutWidget(screenSize: screenSize)
          ],
        ),
      ),
    );
  }
}
