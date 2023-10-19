import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

AppBar largeGradientAppBar(String label) {
  return AppBar(
    toolbarHeight: 85,
    flexibleSpace: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
      CustomColors.jigglypuff,
      CustomColors.love,
    ]))),
    title: Center(
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
  );
}
