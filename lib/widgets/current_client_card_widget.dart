import 'package:fitnessco/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';

class CurrentClientCard extends StatelessWidget {
  final String clientUID;
  final String firstName;
  final String lastName;
  final bool isClient;
  const CurrentClientCard(
      {super.key,
      required this.clientUID,
      required this.firstName,
      required this.lastName,
      required this.isClient});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.purple.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                '$firstName $lastName',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    otherPersonUID: clientUID,
                                    isClient: isClient,
                                  )));
                    },
                    child: const Text(
                      'Send Message',
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ClientWorkoutsScreen(clientUID: clientUID),
                        ),
                      );
                    },
                    child: const Text(
                      'View Workout',
                      textAlign: TextAlign.center,
                    )),
              ),
            )
          ],
        ));
  }
}
