// ignore_for_file: file_names

import 'package:fitnessco/widgets/client_requests_container_widget.dart';
import 'package:fitnessco/widgets/current_clients_container_widget.dart';
import 'package:flutter/material.dart';

class TrainerCurrentClients extends StatefulWidget {
  const TrainerCurrentClients({Key? key}) : super(key: key);

  @override
  State<TrainerCurrentClients> createState() => _TrainerCurrentClientsState();
}

class _TrainerCurrentClientsState extends State<TrainerCurrentClients> {
  final GlobalKey<CurrentClientContainerState> currentClientsKey =
      GlobalKey<CurrentClientContainerState>();
  final GlobalKey<ClientRequestsContainerState> currentRequestsKey =
      GlobalKey<ClientRequestsContainerState>();

  void refreshCurrentClients() {
    currentClientsKey.currentState?.getAllCurrentClients();
    currentRequestsKey.currentState?.getAllClientRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Clients')),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                color: Colors.purple.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Client Requests',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClientRequestsContainer(
                            key: currentRequestsKey,
                            refreshParent: refreshCurrentClients,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.purple.withOpacity(0.4),
                child: Column(
                  children: [
                    const Text(
                      'Current Clients',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.white),
                    ),
                    CurrentClientContainer(
                      key: currentClientsKey,
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
