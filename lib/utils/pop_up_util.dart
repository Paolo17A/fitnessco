import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, {required String label}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: CustomColors.purpleSnail.withOpacity(0.75),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 50, 5, 5),
                  child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Center(
                              child: SingleChildScrollView(
                                child: futuraText(label,
                                    textStyle: blackBoldStyle(size: 25)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: gradientOvalButton(
                                label: 'CONTINUE',
                                onTap: () => Navigator.of(context).pop()),
                          )
                        ],
                      )),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/icons/error_icon.png'),
                    ))
              ]),
            ),
          ));
}

void showSuccessMessage(BuildContext context,
    {required String label, required Function onPress}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: CustomColors.purpleSnail.withOpacity(0.75),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 50, 5, 5),
                  child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: SingleChildScrollView(
                              child: futuraText(label,
                                  textStyle: blackBoldStyle(size: 25)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: gradientOvalButton(
                                label: 'CONTINUE', onTap: () => onPress),
                          )
                        ],
                      )),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/icons/success_icon.png'),
                    ))
              ]),
            ),
          ));
}
