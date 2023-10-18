import 'package:flutter/material.dart';

Widget clientNavBar({required int currentIndex}) {
  return BottomNavigationBar(currentIndex: currentIndex, items: [
    BottomNavigationBarItem(
        label: 'TRAINERS',
        backgroundColor: Colors.red,
        icon:
            Image.asset('assets/images/icons/view_my_clients.png', scale: 50)),
    BottomNavigationBarItem(
        label: 'WORKOUT PLAN',
        icon: Image.asset('assets/images/icons/view_workouts_plan.png',
            scale: 50)),
    BottomNavigationBarItem(
        label: 'PERSONAL HISTORY',
        icon: Image.asset('assets/images/icons/profile_description.png',
            scale: 50))
  ]);
}
