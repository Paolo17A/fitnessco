import 'package:flutter/material.dart';

class ClientRequestCard extends StatelessWidget {
  final String clientUID;
  final String firstName;
  final String lastName;
  final Function approveReq;
  final Function denyReq;
  const ClientRequestCard(
      {super.key,
      required this.clientUID,
      required this.firstName,
      required this.lastName,
      required this.approveReq,
      required this.denyReq});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.withOpacity(0.6),
      child: ListTile(
        title: Text(
          '$firstName $lastName',
          style: const TextStyle(
              fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () {
                  approveReq();
                }),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                denyReq();
              },
            ),
          ],
        ),
      ),
    );
  }
}
