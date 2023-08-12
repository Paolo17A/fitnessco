import 'package:flutter/material.dart';

void removeProfilePicDialogue(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Remove Profile Picture'),
      content:
          const Text('Are you sure you want to remove your profile picture?'),
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
