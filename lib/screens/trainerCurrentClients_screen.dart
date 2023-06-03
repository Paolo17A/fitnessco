import 'package:flutter/material.dart';
import '../widgets/ClientRequest_widget.dart';

class TrainerCurrentClients extends StatelessWidget {
  final List<String> clientUIDs;

  const TrainerCurrentClients({Key? key, required this.clientUIDs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Current Clients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: clientUIDs.length,
          itemBuilder: (context, index) {
            return ClientRequest(clientUID: clientUIDs[index]);
          },
        ),
      ],
    );
  }
}
