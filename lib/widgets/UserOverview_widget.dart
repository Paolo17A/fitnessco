import 'package:flutter/material.dart';

class UserOverview extends StatelessWidget {
  final String firstName;
  final String lastName;

  const UserOverview(
      {Key? key, required this.firstName, required this.lastName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purpleAccent.withOpacity(0.3),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.amber,
        ),
        title: Text("$firstName $lastName"),
        trailing: ElevatedButton(
          child: const Text("View Profile"),
          onPressed: () {
            // Navigate to user profile screen
          },
        ),
      ),
    );
  }
}
