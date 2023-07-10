import 'package:flutter/material.dart';

void removeProfilePicDialogue(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Quit'),
      content:
          const Text('Are you sure you want to renove your profile picture?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}
