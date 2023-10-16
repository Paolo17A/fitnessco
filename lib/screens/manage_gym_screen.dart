import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/pop_up_util.dart';
import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/fitnessco_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class ManageGymScreen extends StatefulWidget {
  const ManageGymScreen({super.key});
  @override
  ManageGymScreenState createState() => ManageGymScreenState();
}

class ManageGymScreenState extends State<ManageGymScreen> {
  //  MEMBERSHIP RATES
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _weeklyRateController = TextEditingController();
  final TextEditingController _monthlyRateController = TextEditingController();
  final TextEditingController _downWeeklyRateController =
      TextEditingController();
  final TextEditingController _downMonthlyRateController =
      TextEditingController();
  final TextEditingController _commissionRateController =
      TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGymSettings();
  }

  void _fetchGymSettings() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('settings')
          .get();

      final data = documentSnapshot.data()! as Map<String, dynamic>;
      //  MEMBERSHIP RATES

      //  Handle Daily Membership Rates
      if (!data.containsKey('dailyMembershipRate')) {
        await FirebaseFirestore.instance
            .collection('gym_settings')
            .doc('settings')
            .update({'dailyMembershipRate': 0.0});
        _dailyRateController.text = (0.0).toStringAsFixed(2);
      } else {
        _dailyRateController.text =
            data['dailyMembershipRate'].toStringAsFixed(2);
      }

      //  Handle Weekly Membership Rates
      if (!data.containsKey('weeklyMembershipRate')) {
        await FirebaseFirestore.instance
            .collection('gym_settings')
            .doc('settings')
            .update({'weeklyMembershipRate': 0.0});
        _weeklyRateController.text = (0.0).toStringAsFixed(2);
      } else {
        _weeklyRateController.text =
            data['weeklyMembershipRate'].toStringAsFixed(2);
      }

      //  Handle Weekly Membership Rates
      if (!data.containsKey('monthlyMembershipRate')) {
        await FirebaseFirestore.instance
            .collection('gym_settings')
            .doc('settings')
            .update({'monthlyMembershipRate': 0.0});
        _monthlyRateController.text = (0.0).toStringAsFixed(2);
      } else {
        _monthlyRateController.text =
            data['monthlyMembershipRate'].toStringAsFixed(2);
      }

      //  Handle Down Weekly Membership Rates
      if (!data.containsKey('downWeeklyMembershipRate')) {
        await FirebaseFirestore.instance
            .collection('gym_settings')
            .doc('settings')
            .update({'downWeeklyMembershipRate': 0.0});
        _downWeeklyRateController.text = (0.0).toStringAsFixed(2);
      } else {
        _downWeeklyRateController.text =
            data['downWeeklyMembershipRate'].toStringAsFixed(2);
      }

      //  Handle Down Monthly Membership Rates
      if (!data.containsKey('downMonthlyMembershipRate')) {
        await FirebaseFirestore.instance
            .collection('gym_settings')
            .doc('settings')
            .update({'downMonthlyMembershipRate': 0.0});
        _downMonthlyRateController.text = (0.0).toStringAsFixed(2);
      } else {
        _downMonthlyRateController.text =
            data['downMonthlyMembershipRate'].toStringAsFixed(2);
      }

      //  COMMISSION
      _commissionRateController.text =
          data['commission_rate'].toStringAsFixed(2);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving membership status: $e"),
        backgroundColor: Colors.purple,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveGymSettings() async {
    // Store the gym settings in Firebase Firestore
    double dailyMembershipRate =
        double.tryParse(_dailyRateController.text) ?? 0.0;
    double weeklyMembershipRate =
        double.tryParse(_weeklyRateController.text) ?? 0.0;
    double monthlyMembershipRate =
        double.tryParse(_monthlyRateController.text) ?? 0.0;
    double downWeeklyMembershipRate =
        double.tryParse(_downWeeklyRateController.text) ?? 0.0;
    double downMonthlyMembershipRate =
        double.tryParse(_downMonthlyRateController.text) ?? 0.0;
    double commissionRate =
        double.tryParse(_commissionRateController.text) ?? 0.0;

    try {
      await FirebaseFirestore.instance
          .collection('gym_settings')
          .doc('settings')
          .set({
        'dailyMembershipRate': dailyMembershipRate,
        'weeklyMembershipRate': weeklyMembershipRate,
        'monthlyMembershipRate': monthlyMembershipRate,
        'downWeeklyMembershipRate': downWeeklyMembershipRate,
        'downMonthlyMembershipRate': downMonthlyMembershipRate,
        'commission_rate': commissionRate,
      });

      // Show a snackbar to indicate successful saving of gym settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gym settings saved')),
      );
    } catch (e) {
      showErrorMessage(context, label: 'Error saving gym settings: $e');
    }
  }

  @override
  void dispose() {
    _dailyRateController.dispose();
    _weeklyRateController.dispose();
    _monthlyRateController.dispose();
    _commissionRateController.dispose();
    _downWeeklyRateController.dispose();
    _downMonthlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              title: Center(
                child: futuraText('Manage Gym Membership',
                    textStyle: whiteBoldStyle()),
              ),
              elevation: 0),
          body: switchedLoadingContainer(
              _isLoading,
              userAuthBackgroundContainer(
                context,
                child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    futuraText('Gym Membership Rates',
                                        textStyle: blackBoldStyle(size: 25)),
                                  ],
                                ),
                              ),
                              roundedContainer(
                                  color: CustomColors.mercury.withOpacity(0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        gymFeeRow(context,
                                            label: 'DAILY MEMBERSHIP RATE',
                                            textField: fitnesscoTextField(
                                                'Daily Membership Rate',
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                                _dailyRateController)),
                                        const SizedBox(height: 30),
                                        gymFeeRow(context,
                                            label: 'WEEKLY MEMBERSHIP RATE',
                                            textField: fitnesscoTextField(
                                                'Weekly Membership Rate',
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                                _weeklyRateController)),
                                        const SizedBox(height: 30),
                                        gymFeeRow(context,
                                            label: 'MONTHLY MEMBERSHIP RATE',
                                            textField: fitnesscoTextField(
                                                'Monthly Membership Rate',
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                                _monthlyRateController)),
                                        const SizedBox(height: 30),
                                        gymFeeRow(context,
                                            label:
                                                'DOWN PAYMENT WEEKLY MEMBERSHIP RATE',
                                            textField: fitnesscoTextField(
                                                'Down Payment Weekly Membership Rate',
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                                _downWeeklyRateController)),
                                        const SizedBox(height: 30),
                                        gymFeeRow(context,
                                            label:
                                                'DOWN PAYMENT MONTHLY MEMBERSHIP RATE',
                                            textField: fitnesscoTextField(
                                                'Down Payment Monthly Membership Rate',
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                                _downMonthlyRateController)),
                                        const SizedBox(height: 16.0),
                                      ],
                                    ),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: gradientOvalButton(
                                    label: 'Save Gym Settings',
                                    width: 250,
                                    radius: 40,
                                    onTap: _saveGymSettings),
                              )
                            ]),
                      )),
                ),
              ))),
    );
  }
}
