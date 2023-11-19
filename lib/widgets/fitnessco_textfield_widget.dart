import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnesscoTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Icon? displayPrefixIcon;
  final bool enabled;
  const FitnesscoTextField(
      {super.key,
      required this.text,
      required this.controller,
      required this.textInputType,
      required this.displayPrefixIcon,
      this.enabled = true});

  @override
  State<FitnesscoTextField> createState() => _FitnesscoTextFieldState();
}

class _FitnesscoTextFieldState extends State<FitnesscoTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        enabled: widget.enabled,
        controller: widget.controller,
        obscureText: isObscured,
        cursorColor: CustomColors.purpleSnail,
        style: TextStyle(color: CustomColors.purpleSnail),
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.text,
            labelStyle: TextStyle(
                color: CustomColors.purpleSnail.withOpacity(0.5),
                fontStyle: FontStyle.italic),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white.withOpacity(0.4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                    color: CustomColors.purpleSnail, width: 3.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            prefixIcon: widget.displayPrefixIcon,
            suffixIcon: widget.textInputType == TextInputType.visiblePassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      color: CustomColors.purpleSnail.withOpacity(0.6),
                    ))
                : null),
        keyboardType: widget.textInputType,
        maxLines: widget.textInputType == TextInputType.multiline ? 4 : 1);
  }
}

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
