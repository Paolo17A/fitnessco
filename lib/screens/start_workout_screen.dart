import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/navigation_bar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/color_utils.dart';
import '../widgets/custom_text_widgets.dart';

class StartWorkoutScreen extends StatelessWidget {
  final Map<dynamic, dynamic> workoutForToday;
  StartWorkoutScreen({super.key, required this.workoutForToday});

  @override
  Widget build(BuildContext context) {
    print(workoutForToday);
    return Scaffold(
        bottomNavigationBar: clientNavBar(context, currentIndex: 0),
        body: startWorkoutBackgroundContainer(
          context,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [
                _gradientDate(context),
                _workoutsCarousel(context),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/warmUp'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.plasmaTrail,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: futuraText('Start Workout',
                            textStyle: whiteBoldStyle()),
                      )),
                )
              ]),
            ),
          ),
        ));
  }

  Widget _gradientDate(BuildContext context) {
    return Column(children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  colors: [CustomColors.bananaMilk, CustomColors.jigglypuff])),
          child: Center(
              child: futuraText(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  textStyle: blackBoldStyle(size: 36))),
        ),
      ),
    ]);
  }

  Widget _workoutsCarousel(BuildContext context) {
    final musclesList = workoutForToday.keys.toList();
    List<dynamic> workouts = [];
    for (var muscle in musclesList) {
      final muscleMap = workoutForToday[muscle] as Map<dynamic, dynamic>;
      for (var element in muscleMap.entries) {
        workouts.add(element.key);
      }
    }

    return roundedContainer(
      height: 170,
      color: const Color.fromARGB(255, 209, 209, 209),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CarouselSlider.builder(
            itemCount: workouts.length,
            itemBuilder: ((context, index, _) {
              return roundedContainer(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      futuraText(workouts[index], textStyle: blackBoldStyle()),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: 75,
                          color: Colors.white,
                          child: Image.asset(
                              'assets/images/gifs/${workouts[index]}.gif')),
                    ],
                  ));
            }),
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.35,
                viewportFraction: 0.5,
                enableInfiniteScroll: false)),
      ),
    );
  }
}
