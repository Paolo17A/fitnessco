import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> displayQuitDialogue(BuildContext context) async {
  final shouldQuit = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirm Quit'),
      content: const Text('Are you sure you want to quit?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Quit'),
        ),
      ],
    ),
  );

  if (shouldQuit == true) {
    SystemNavigator.pop();
  }

  return shouldQuit;
}
