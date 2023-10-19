import 'package:flutter/material.dart';
import '../widgets/custom_text_widgets.dart';

void showSelectedDateOptions(BuildContext context,
    {required bool hasWorkout,
    required Function onSelectedPrescribe,
    required onSelectedDelete}) {
  showModalBottomSheet(
      context: context,
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (hasWorkout) {
          return Wrap(
            children: [
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  title: Center(
                    child:
                        futuraText('EDIT WORKOUT', textStyle: blackBoldStyle()),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectedPrescribe();
                  }),
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  title: Center(
                    child: futuraText('REMOVE WORKOUT',
                        textStyle: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => onSelectedDelete()),
            ],
          );
        } else {
          return Wrap(children: [
            SizedBox(
              height: 100,
              child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  title: Center(
                    child:
                        futuraText('ADD WORKOUT', textStyle: blackBoldStyle()),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectedPrescribe();
                  }),
            ),
          ]);
        }
      });
}
