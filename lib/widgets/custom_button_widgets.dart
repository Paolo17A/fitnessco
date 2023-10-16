// ignore_for_file: file_names

import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

Container ovalButton(BuildContext context, String text, Function onTap) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.black26;
                }
                return Colors.white;
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)))),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16))));
}

Widget gradientOvalButton(
    {required String label,
    required Function onTap,
    double? radius = 20,
    double? width = 150,
    double? height = 50}) {
  return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 0),
          gradient: LinearGradient(
              colors: [CustomColors.plasmaTrail, CustomColors.nightSnow])),
      child: TextButton(
          onPressed: (() => onTap()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius ?? 0)),
          ),
          child: futuraText(label, textStyle: whiteBoldStyle())));
}
