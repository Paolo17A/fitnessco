// ignore_for_file: file_names

import 'package:fitnessco/widgets/client_requests_container_widget.dart';
import 'package:fitnessco/widgets/current_clients_container_widget.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

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
      extendBodyBehindAppBar: true,
      appBar: _myClientsAppBar(),
      body: viewTrainerBackgroundContainer(
        context,
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
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
                  const SizedBox(height: 20),
                  CurrentClientContainer(key: currentClientsKey)
                ],
              )),
        ),
      ),
    );
  }

  AppBar _myClientsAppBar() {
    return AppBar(
      toolbarHeight: 85,
      flexibleSpace: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
        CustomColors.jigglypuff,
        CustomColors.love,
      ]))),
      title: Center(
          child: Text('My Clients',
              style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
