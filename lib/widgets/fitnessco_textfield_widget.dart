import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextField fitnesscoTextField(
    String text, TextInputType textInputType, TextEditingController controller,
    {IconData? icon,
    int? maxLines = 6,
    Color? typeColor = CustomColors.purpleSnail,
    bool? isEditable = true}) {
  return TextField(
      controller: controller,
      obscureText:
          textInputType == TextInputType.visiblePassword ? true : false,
      enableSuggestions:
          textInputType == TextInputType.visiblePassword ? true : false,
      autocorrect:
          textInputType == TextInputType.visiblePassword ? true : false,
      cursorColor: CustomColors.purpleSnail,
      maxLines: textInputType == TextInputType.multiline ? maxLines : 1,
      enabled: isEditable,
      style: GoogleFonts.nunitoSans(textStyle: TextStyle(color: typeColor)),
      decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: CustomColors.purpleSnail,
                )
              : null,
          labelText: text,
          labelStyle:
              GoogleFonts.nunitoSans(textStyle: TextStyle(color: typeColor)),
          alignLabelWithHint: true,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(width: 1, color: CustomColors.nearMoon))),
      keyboardType: textInputType);
}
