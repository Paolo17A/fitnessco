import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'custom_container_widget.dart';
import 'custom_text_widgets.dart';

Widget fitnesscoLogo() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Transform.scale(
        scale: 0.75,
        child: Image.asset('assets/images/fitnessco_logo_notext.png')),
  );
}

Widget gymFeeRow(BuildContext context,
    {required String label, required Widget textField}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: futuraText(label, textStyle: blackBoldStyle(size: 15)),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: 50,
        child: textField,
      )
    ],
  );
}

Widget homeRowContainer(
    {required String iconPath,
    double? imageScale = 75,
    required String label,
    required Function onPress}) {
  return GestureDetector(
    onTap: () => onPress(),
    child: Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    scale: imageScale,
                  ),
                  const SizedBox(width: 10),
                  futuraText(label,
                      textStyle: TextStyle(color: Colors.black, fontSize: 15)),
                ],
              ),
              Image.asset(
                'assets/images/icons/select_row.png',
                scale: 50,
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: Colors.black,
          )
        ],
      ),
    ),
  );
}

Widget buildProfileImage(
    {required String profileImageURL,
    required double radius,
    Color? backgroundColor = Colors.white,
    Color? iconColor = CustomColors.purpleSnail}) {
  if (profileImageURL != '') {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: NetworkImage(profileImageURL),
    );
  } else {
    return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Transform.scale(
            scale: 2, child: Icon(Icons.person, color: iconColor)));
  }
}

Widget gymRatingRow(
    {required int starCount, required String label, required String price}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RatingBar(
                minRating: 1,
                itemCount: 3,
                initialRating: starCount.toDouble(),
                updateOnDrag: false,
                allowHalfRating: false,
                ignoreGestures: true,
                itemSize: 20,
                ratingWidget: RatingWidget(
                    full: Icon(Icons.star,
                        color: Color.fromARGB(255, 253, 229, 13)),
                    half: Icon(Icons.star, color: Colors.yellow),
                    empty: Icon(Icons.star, color: Colors.grey)),
                onRatingUpdate: (val) {}),
            const SizedBox(width: 5),
            futuraText(label, textStyle: blackBoldStyle(size: 13))
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: futuraText(price,
              textStyle: TextStyle(
                  color: CustomColors.purpleSnail,
                  fontWeight: FontWeight.bold)),
        )
      ],
    ),
  );
}

GestureDetector trainerItemDeleter(BuildContext context,
    {required Function onDelete, required item, required Widget child}) {
  return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: CustomColors.mercury,
                content: roundedContainer(
                    child: Text('Do you want to remove $item?')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal))),
                  TextButton(
                      onPressed: () => onDelete(),
                      child: Text('REMOVE',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal)))
                ],
              );
            });
      },
      child: child);
}

Widget clientProfileImage(String profileImageURL) {
  return buildProfileImage(
      profileImageURL: profileImageURL,
      radius: 50,
      backgroundColor: Color.fromARGB(255, 165, 163, 163),
      iconColor: Colors.white);
}

Widget trainerProfileImage(String profileImageURL) {
  return buildProfileImage(
      profileImageURL: profileImageURL,
      radius: 50,
      backgroundColor: CustomColors.mercury,
      iconColor: Color.fromARGB(255, 165, 163, 163));
}

Widget trainerProfileContent(BuildContext context, String firstName,
    String lastName, List<dynamic> currentClients, String sex, num age) {
  return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Column(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: futuraText('$firstName $lastName',
              textStyle: TextStyle(
                  color: CustomColors.purpleSnail,
                  fontWeight: FontWeight.bold,
                  fontSize: 23)),
        ),
        Row(children: [
          futuraText(sex, textStyle: blackBoldStyle(size: 13)),
          const SizedBox(width: 10),
          futuraText('${age.toInt().toString()} years old')
        ]),
        futuraText('${currentClients.length.toString()} Clients',
            textStyle: blackBoldStyle(size: 15))
      ]));
}

Widget clientProfileContent(BuildContext context, String firstName,
    String lastName, String sex, num age) {
  return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            futuraText('$firstName $lastName',
                textStyle: TextStyle(
                    color: CustomColors.purpleSnail,
                    fontWeight: FontWeight.bold,
                    fontSize: 23)),
            futuraText(sex, textStyle: blackBoldStyle(size: 13)),
            futuraText('${age.toInt().toString()} years old')
          ],
        ),
      ));
}

Widget userDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(thickness: 2, color: Colors.grey),
  );
}

Widget customDayWidget(bool isSelectedDay, int day) {
  return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: isSelectedDay
                  ? [CustomColors.mintZest, CustomColors.nearMoon]
                  : [CustomColors.jigglypuff, CustomColors.purpleSnail])),
      child: Center(child: Text(day.toString(), style: whiteBoldStyle())));
}
