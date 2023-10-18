import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, List<Widget> children) {
  return Stack(children: [
    ...children,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Container roundedContainer(
    {required Widget child,
    Color? color,
    double? width,
    double? height,
    Color? borderColor}) {
  return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null),
      child: child);
}

Widget welcomeBackgroundContainer(BuildContext context,
    {required Widget child}) {
  return SingleChildScrollView(
    child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/loading.png'),
                fit: BoxFit.cover)),
        child: child),
  );
}

Widget userAuthBackgroundContainer(BuildContext context,
    {required Widget child}) {
  return SingleChildScrollView(
    child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/register.png'),
                fit: BoxFit.cover)),
        child: child),
  );
}

Widget homeBackgroundContainer(BuildContext context, {required Widget child}) {
  return SingleChildScrollView(
    child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/main client dashboard.png'),
                fit: BoxFit.cover)),
        child: child),
  );
}

Widget gymRatesBackgroundContainer(BuildContext context,
    {required Widget child}) {
  return SingleChildScrollView(
    child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image:
                    AssetImage('assets/images/backgrounds/view gym rates.png'),
                fit: BoxFit.cover)),
        child: child),
  );
}

Widget viewTrainerBackgroundContainer(BuildContext context,
    {required Widget child}) {
  return SingleChildScrollView(
    child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/VIEW TRAINER BACKGROUND.png'),
                fit: BoxFit.cover)),
        child: child),
  );
}

Widget borderedTextContainer(String label, String textInput) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Text(label),
            ],
          ),
        ),
        Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            child: Center(
              child: futuraText(textInput),
            )),
      ],
    ),
  );
}

Widget sunGradientBox({required String label}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Container(
      width: 130,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
              colors: [CustomColors.bananaMilk, CustomColors.jigglypuff])),
      child: Center(
          child: SingleChildScrollView(
              child: futuraText(label, textStyle: blackBoldStyle()))),
    ),
  );
}

Widget moonGradientBox({required String label}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Container(
      width: 130,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
              colors: [CustomColors.mintZest, CustomColors.trueSky])),
      child: Center(
          child: SingleChildScrollView(
              child: futuraText(label, textStyle: blackBoldStyle()))),
    ),
  );
}
