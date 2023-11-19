import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_miscellaneous_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

class GymRatesScreen extends StatefulWidget {
  const GymRatesScreen({super.key});

  @override
  State<GymRatesScreen> createState() => _GymRatesScreenState();
}

class _GymRatesScreenState extends State<GymRatesScreen> {
  bool _isLoading = true;
  double dailyMembershipRate = 0;
  double weeklyMembershipRate = 0;
  double monthlyMembershipRate = 0;
  double downWeeklyMembershipRate = 0;
  double downMonthlyMembershipRate = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getGymRates();
  }

  Future getGymRates() async {
    try {
      final gym = await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('settings')
          .get();
      final gymSettings = gym.data()!;
      dailyMembershipRate = gymSettings['dailyMembershipRate'] as double;
      weeklyMembershipRate = gymSettings['weeklyMembershipRate'];
      monthlyMembershipRate = gymSettings['monthlyMembershipRate'];
      downWeeklyMembershipRate = gymSettings['downWeeklyMembershipRate'];
      downMonthlyMembershipRate = gymSettings['downMonthlyMembershipRate'];
      setState(() {
        _isLoading = false;
      });
      print('GYM SETTINGS: $gymSettings');
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorMessage(context, label: 'Error getting Gym Rates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(elevation: 0),
      body: stackedLoadingContainer(context, _isLoading, [
        gymRatesBackgroundContainer(context,
            child: SafeArea(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: futuraText('Gym Membership Rates',
                      textStyle: whiteBoldStyle(size: 30)),
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(children: [
                        gymRatingRow(
                            starCount: 1,
                            label: 'DAILY',
                            price: '${dailyMembershipRate.toStringAsFixed(2)}'),
                        gymRatingRow(
                            starCount: 2,
                            label: 'WEEKLY',
                            price:
                                '${weeklyMembershipRate.toStringAsFixed(2)}'),
                        gymRatingRow(
                            starCount: 3,
                            label: 'MONTHLY',
                            price:
                                '${monthlyMembershipRate.toStringAsFixed(2)}'),
                        const SizedBox(height: 13),
                        futuraText('payment first is a must',
                            textStyle: TextStyle(fontSize: 10))
                      ]),
                    )),
                const SizedBox(height: 30),
                Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(children: [
                        gymRatingRow(
                            starCount: 1,
                            label: 'DOWN WEEKLY',
                            price:
                                '${downWeeklyMembershipRate.toStringAsFixed(2)}/ gym visit'),
                        gymRatingRow(
                            starCount: 2,
                            label: 'DOWN MONTHLY',
                            price:
                                '${downMonthlyMembershipRate.toStringAsFixed(2)}/ gym visit'),
                        const SizedBox(height: 13),
                        futuraText('missing a payment may cause gym suspension',
                            textStyle: TextStyle(fontSize: 10))
                      ]),
                    )),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: futuraText(
                          'GO TO THE ADMIN FRONT DESK FOR INQUIRIES ON CHANGING YOUR MEMBERSHIP PLAN.')),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 92, 224, 213),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: futuraText('CONTINUE',
                            textStyle: whiteBoldStyle(size: 15))))
              ],
            )))
      ]),
    );
  }
}
