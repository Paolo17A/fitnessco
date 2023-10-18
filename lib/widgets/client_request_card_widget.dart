import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

class ClientRequestCard extends StatelessWidget {
  final String clientUID;
  final String firstName;
  final String lastName;
  final String profileImageURL;
  final Function approveReq;
  final Function denyReq;
  const ClientRequestCard(
      {super.key,
      required this.clientUID,
      required this.firstName,
      required this.lastName,
      required this.profileImageURL,
      required this.approveReq,
      required this.denyReq});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.love,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 80,
          child: Row(children: [
            buildProfileImage(profileImageURL: profileImageURL, radius: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: futuraText('$firstName $lastName',
                            textStyle: greyBoldStyle(size: 14)),
                      ),
                      ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: futuraText('View Profile',
                              textStyle: blackBoldStyle(size: 12)))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                            onPressed: () => approveReq(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: futuraText('ACCEPT',
                                textStyle: blackBoldStyle(size: 12))),
                      ),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                            onPressed: () => denyReq,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: futuraText('DENY',
                                textStyle: blackBoldStyle(size: 12))),
                      )
                    ],
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
