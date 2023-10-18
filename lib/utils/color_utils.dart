import 'package:flutter/material.dart';

class CustomColors {
  static const Color bananaMilk = Color.fromARGB(255, 255, 247, 173); //#FFF7AD
  static const Color electricLavender =
      Color.fromARGB(255, 254, 205, 255); //#fecdff
  static const Color jigglypuff = Color.fromARGB(255, 255, 169, 249); //#ffa9f9
  static const Color love = Color.fromARGB(255, 255, 222, 242);
  static const Color mercury = Color.fromARGB(255, 235, 235, 235);
  static const Color mintZest = Color.fromARGB(255, 205, 255, 216); //#cdffd8
  static const Color nearMoon = Color.fromARGB(255, 92, 225, 230); //#5CE1E6
  static const Color nightSnow = Color.fromARGB(255, 163, 197, 255); //#A3C5FF
  static const Color purpleSnail = Color.fromARGB(255, 203, 108, 230); //#CB6CE6
  static const Color plasmaTrail = Color.fromARGB(255, 220, 144, 251); //#D390FB
  static const Color rosePink = Color.fromARGB(255, 255, 102, 196); //#ff66c4

  static const Color trueSky = Color.fromARGB(255, 148, 185, 255); //#94b9ff
}

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}
