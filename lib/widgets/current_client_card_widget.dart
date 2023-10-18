import 'package:fitnessco/screens/chat_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';

class CurrentClientCard extends StatelessWidget {
  final String clientUID;
  final String firstName;
  final String lastName;
  final bool isClient;
  final String profileImageURL;
  const CurrentClientCard(
      {super.key,
      required this.clientUID,
      required this.firstName,
      required this.lastName,
      required this.isClient,
      required this.profileImageURL});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: buildProfileImage(
                            profileImageURL: profileImageURL, radius: 30)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Column(
                        children: [
                          Text(
                            '$firstName $lastName',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 30,
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: Text('View Profile',
                                    textAlign: TextAlign.center,
                                    style: blackBoldStyle(size: 9))),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 30,
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.jigglypuff,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: futuraText('Send Messge',
                              textStyle: blackBoldStyle(size: 10))),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 30,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ClientWorkoutsScreen(
                                      clientUID: clientUID)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.jigglypuff,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: futuraText('View Workouts',
                              textStyle: whiteBoldStyle(size: 10))),
                    )
                  ])),
          Divider(thickness: 1.5)
        ]));
  }
}
