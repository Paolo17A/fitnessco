import 'package:flutter/material.dart';

void removeProfilePicDialogue(BuildContext context,
    {required Function onRemove}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Remove Profile Picture'),
      content:
          const Text('Are you sure you want to remove your profile picture?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRemove();
          },
          child: const Text('Remove', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
