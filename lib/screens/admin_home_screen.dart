import 'package:fitnessco/screens/all_clients_screen.dart';
import 'package:fitnessco/screens/manage_gym_screen.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/home_app_bar_widget.dart';
import 'package:flutter/material.dart';
import '../utils/quit_dialogue_util.dart';
import '../widgets/custom_container_widget.dart';
import 'all_trainers_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _goToAllTrainersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllTrainersScreen(),
      ),
    );
  }

  void _goToAllClientsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllClientsScreen(),
      ),
    );
  }

  void _goToManageGymScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ManageGymScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => displayQuitDialogue(context),
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: homeAppBar(context),
            body: userAuthBackgroundContainer(context,
                child: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        futuraText('FITNESSCO',
                                            textAlign: TextAlign.left,
                                            textStyle: TextStyle(
                                                color: CustomColors.purpleSnail,
                                                fontSize: 25)),
                                        futuraText('Admin Panel',
                                            textAlign: TextAlign.left,
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25))
                                      ],
                                    )
                                  ],
                                ),
                                adminHomeScreenButton(context,
                                    label: 'View All Trainers',
                                    onTap: () =>
                                        _goToAllTrainersScreen(context),
                                    imagePath:
                                        'assets/images/icons/view_all_trainers.png',
                                    imageScale: 1.15,
                                    color: CustomColors.purpleSnail),
                                const SizedBox(height: 15),
                                adminHomeScreenButton(context,
                                    label: 'View All Clients',
                                    onTap: () => _goToAllClientsScreen(context),
                                    imagePath:
                                        'assets/images/icons/view_all_clients.png',
                                    imageScale: 1.5,
                                    color: Color.fromARGB(255, 94, 200, 204)),
                                const SizedBox(height: 15),
                                adminHomeScreenButton(context,
                                    label: 'Manage Gym Membership',
                                    onTap: () => _goToManageGymScreen(context),
                                    imagePath:
                                        'assets/images/icons/manage_gym_membership.png',
                                    imageScale: 1,
                                    color: Color.fromARGB(255, 25, 73, 161))
                              ])
                            ]))))));
  }

  Widget adminHomeScreenButton(BuildContext context,
      {required String label,
      required Function onTap,
      required String imagePath,
      double? imageScale = 1,
      required Color color}) {
    return SizedBox(
      height: 150,
      child: ElevatedButton(
        onPressed: () => onTap(),
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: futuraText(label,
                          textAlign: TextAlign.left,
                          textStyle: whiteBoldStyle(size: 25)),
                    ),
                  ],
                )),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      child: Transform.scale(
                    scale: imageScale,
                    child: Image.asset(
                      imagePath,
                      height: 150,
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
