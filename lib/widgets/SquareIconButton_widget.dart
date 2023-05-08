// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';

Widget squareIconButton_Widget(
    BuildContext context, String title, IconData icon, Function onTap,
    {double iconSize = 50.0,
    double buttonWidth = 100,
    double buttonHeight = 100}) {
  return ElevatedButton(
    onPressed: () {
      onTap();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      minimumSize: Size(buttonWidth, buttonHeight),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Theme.of(context).cardColor,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
