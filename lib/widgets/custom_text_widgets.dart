import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget futuraText(String label,
    {TextAlign? textAlign = TextAlign.center, TextStyle? textStyle}) {
  return Text(label,
      textAlign: textAlign,
      style: GoogleFonts.nunitoSans(textStyle: textStyle));
}

TextStyle blackBoldStyle({double? size = 20}) {
  return TextStyle(
      fontSize: size, color: Colors.black, fontWeight: FontWeight.bold);
}

TextStyle whiteBoldStyle({double? size = 20}) {
  return TextStyle(
      fontSize: size, color: Colors.white, fontWeight: FontWeight.bold);
}
