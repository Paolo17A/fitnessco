import 'package:flutter/material.dart';

class CurrentClientCard extends StatelessWidget {
  final String clientUID;
  final String firstName;
  final String lastName;
  const CurrentClientCard({
    super.key,
    required this.clientUID,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.withOpacity(0.4),
      child: ListTile(
          title: Text(
            '$firstName $lastName',
            style: const TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          trailing: ElevatedButton(
              onPressed: () {}, child: const Text('Send Message'))),
    );
  }
}
