import 'package:flutter/material.dart';

Future<void> displayGymRates(
    BuildContext context, Map<String, dynamic> gymSettings) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.deepPurple,
      title: const Text('GYM MEMBERSHIP RATES',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _rateWidget('Daily Rate: ',
                  '${(gymSettings['dailyMembershipRate'] as double).toStringAsFixed(2)}'),
              _rateWidget('Weekly Rate: ',
                  '${(gymSettings['weeklyMembershipRate'] as double).toStringAsFixed(2)}'),
              _rateWidget('Monthly Rate: ',
                  '${(gymSettings['monthlyMembershipRate'] as double).toStringAsFixed(2)}'),
              _rateWidget('Down Weekly Rate: ',
                  '${(gymSettings['downWeeklyMembershipRate'] as double).toStringAsFixed(2)}'),
              _rateWidget('Down Monthly Rate: ',
                  '${(gymSettings['downMonthlyMembershipRate'] as double).toStringAsFixed(2)}'),
              const SizedBox(height: 30),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'GO TO THE ADMIN FRONT DESK FOR INQUIRIES ON CHANGING YOUR PAYMENT PLAN',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w200),
                  ))
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _rateWidget(String _title, String _rate) {
  return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white)),
          Text(_rate,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white)),
        ],
      ));
}
