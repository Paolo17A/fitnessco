import 'package:flutter/material.dart';

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
