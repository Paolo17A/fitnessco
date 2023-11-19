import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showLogOutModal(BuildContext context) {
  showModalBottomSheet(
      context: context,
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      backgroundColor: Colors.transparent,
      builder: (context) => Wrap(
            children: [
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  title: Center(
                    child: futuraText('LOG-OUT',
                        textStyle: TextStyle(
                            color: CustomColors.plasmaTrail,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => showLogOutDialog(context, () async {
                        await FirebaseAuth.instance.signOut();
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.remove('email');
                        sharedPreferences.remove('password');
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      })),
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  title: Center(
                    child: futuraText('LOG-OUT AND EXIT',
                        textStyle: TextStyle(
                            color: CustomColors.plasmaTrail,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => showLogOutDialog(context, () async {
                        await FirebaseAuth.instance.signOut();
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.remove('email');
                        sharedPreferences.remove('password');
                        SystemNavigator.pop();
                      })),
            ],
          ));
}

void showLogOutDialog(BuildContext context, Function onPress) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: CustomColors.plasmaTrail.withOpacity(0.75),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Text(
                      '?',
                      style: whiteBoldStyle(size: 40),
                    ),
                  ),
                  futuraText('Are you sure you want to log-out?',
                      textStyle: blackBoldStyle()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _logOutDialogButton(
                          label: 'CANCEL',
                          color: Colors.red,
                          onPress: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }),
                      _logOutDialogButton(
                          label: 'CONFIRM',
                          color: Colors.green,
                          onPress: onPress)
                    ],
                  )
                ],
              ),
            ),
          ));
}

Widget _logOutDialogButton(
    {required String label, required color, required Function onPress}) {
  return Container(
    width: 100,
    child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(backgroundColor: CustomColors.mercury),
        child: futuraText(label,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: color))),
  );
}
