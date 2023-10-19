import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';

Widget gymHistoryEntryWidget(
    Map<dynamic, dynamic> timeIn, Map<dynamic, dynamic> timeOut) {
  return Padding(
    padding: const EdgeInsets.all(5),
    child: Container(
      decoration: BoxDecoration(
          color: CustomColors.rosePink.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time In: ', style: _style()),
                Text(_dateMapToString(timeIn), style: _style())
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Out: ', style: _style()),
                if (timeOut.isNotEmpty)
                  Text(_dateMapToString(timeOut), style: _style())
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

TextStyle _style() {
  return const TextStyle(
      fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold);
}

String _dateMapToString(Map<dynamic, dynamic> time) {
  int year = time['year'];
  int month = time['month'];
  int day = time['day'];
  int hour = time['hour'];
  int minute = time['minute'];
  int second = time['second'];

  String period = (hour < 12) ? 'AM' : 'PM';
  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }

  String formattedDateTime =
      '$year-${_twoDigits(month)}-${_twoDigits(day)} ${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)} $period';
  return formattedDateTime;
}

String _twoDigits(int n) {
  if (n >= 10) {
    return '$n';
  } else {
    return '0$n';
  }
}
