import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';

Widget clientNavBar(BuildContext context, {required int currentIndex}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: CustomColors.purpleSnail,
    unselectedItemColor: CustomColors.purpleSnail,
    items: [
      BottomNavigationBarItem(
          label: 'TRAINERS', icon: Icon(Icons.fitness_center)),
      BottomNavigationBarItem(
          label: 'WORKOUT PLAN',
          icon: Image.asset('assets/images/icons/view_workouts_plan.png',
              scale: 50)),
      BottomNavigationBarItem(
          label: 'HISTORY',
          icon: Image.asset('assets/images/icons/profile_description.png',
              scale: 50))
    ],
    onTap: (value) {
      if (value == currentIndex) {
        return;
      }
      switch (value) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
          break;
        case 1:
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ClientWorkoutsScreen(
                  clientUID: FirebaseAuth.instance.currentUser!.uid)));
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed('/workoutHistory');
          break;
      }
    },
  );
}

Widget trainerNavBar(BuildContext context, {required int currentIndex}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: CustomColors.purpleSnail,
    items: [
      BottomNavigationBarItem(
          label: 'CLIENTS',
          icon: Image.asset('assets/images/icons/view_my_clients.png',
              scale: 50)),
      BottomNavigationBarItem(
          label: 'SCHEDULE',
          icon: Image.asset('assets/images/icons/view_workouts_plan.png',
              scale: 50)),
      BottomNavigationBarItem(
          label: 'PROFILE',
          icon: Image.asset('assets/images/icons/profile_description.png',
              scale: 50))
    ],
    onTap: (value) {
      if (value == currentIndex) {
        return;
      }
      switch (value) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/trainerCurrentClients');
          break;
        case 1:
          Navigator.of(context).pushReplacementNamed('/trainerSchedule');
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed('/editTrainerProfile');
          break;
      }
    },
  );
}

Widget adminNavBar(BuildContext context, {required int currentIndex}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: CustomColors.purpleSnail,
    unselectedItemColor: CustomColors.purpleSnail,
    items: [
      BottomNavigationBarItem(
          label: 'TRAINERS',
          icon: Image.asset('assets/images/icons/view_workouts_plan.png',
              scale: 50)),
      BottomNavigationBarItem(
          label: 'CLIENTS',
          icon: Image.asset('assets/images/icons/view_my_clients.png',
              scale: 50)),
      BottomNavigationBarItem(
          label: 'MANAGE GYM', icon: Icon(Icons.price_check_rounded))
    ],
    onTap: (value) {
      if (value == currentIndex) {
        return;
      }
      switch (value) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/viewAllTrainers');
          break;
        case 1:
          Navigator.of(context).pushReplacementNamed('/viewAllClients');
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed('/manageGym');
          break;
      }
    },
  );
}
