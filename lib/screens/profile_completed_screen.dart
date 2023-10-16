import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

class ProfileCompletedScreen extends StatelessWidget {
  const ProfileCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
            child: userAuthBackgroundContainer(context,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: roundedContainer(
                        height: MediaQuery.of(context).size.height * 0.75,
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    backgroundImage: AssetImage(
                                        'assets/images/icons/success_icon.png'),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: futuraText(
                                      'THANK YOU FOR COMPLETING YOUR PROFILE. YOU CAN NOW VISIT YOUR DASHBOARD',
                                      textStyle: blackBoldStyle(size: 30)),
                                ),
                                gradientOvalButton(
                                    label: 'CONTINUE',
                                    width: 250,
                                    onTap: () => Navigator.of(context)
                                        .pushReplacementNamed('/clientHome'))
                              ],
                            ))),
                  ),
                ))),
      ),
    );
  }
}
