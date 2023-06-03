import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClientRequest extends StatelessWidget {
  final String clientUID;

  const ClientRequest({Key? key, required this.clientUID}) : super(key: key);

  void _approveRequest(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(clientUID)
          .update({'isConfirmed': true});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Training request approved"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error approving training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  void _denyRequest(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(clientUID)
          .update({'currentTrainer': null});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Training request denied"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error denying training request: $e"),
        backgroundColor: Colors.purple,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(clientUID)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                var clientData = snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  '${clientData['firstName']} ${clientData['lastName']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
            }
            return SizedBox.shrink();
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _approveRequest(context),
              child: Text('Approve'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _denyRequest(context),
              child: Text('Deny'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
