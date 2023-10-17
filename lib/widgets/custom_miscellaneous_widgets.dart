import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    {required String profileImageURL, required double radius}) {
  if (profileImageURL != '') {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(profileImageURL),
    );
  } else {
    return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Transform.scale(
          scale: 2,
          child: Icon(
            Icons.person,
            color: CustomColors.purpleSnail,
          ),
        ));
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
