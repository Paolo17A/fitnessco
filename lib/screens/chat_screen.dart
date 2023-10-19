// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_messages.dart';
import '../widgets/new_message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String otherPersonUID;
  final bool isClient;
  VoidCallback? onCallback;
  ChatScreen(
      {super.key,
      required this.otherPersonUID,
      required this.isClient,
      this.onCallback});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = true;

  String _otherUserFirstName = '';
  String _otherUserLastName = '';

  //  SCHEDULING
  int day = 0;
  int month = 0;
  int year = 0;
  int hour = 0;
  int minute = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getOtherUser();
  }

  void _getOtherUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigatorState = Navigator.of(context);
    //  If the current user is a client, we will get the trainer's data and check if their account has been deleted by the admin
    if (widget.isClient) {
      final trainerData = await getThisUserData(widget.otherPersonUID);
      if (trainerData.data()!['isDeleted'] == true) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Your trainer has been removed by the admin')));
        _deleteTrainer();
      }
    }
    //  If the current user is a trainer, we will get the client's current data and check if we are still their current trainer
    else {
      final clientData = await getThisUserData(widget.otherPersonUID);
      if (clientData.data()!['currentTrainer'] !=
          FirebaseAuth.instance.currentUser!.uid) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text('Your client has opted to select a different trainer')));
        navigatorState.pop();
        return;
      }
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherPersonUID)
        .get()
        .then((value) {
      _otherUserFirstName = value.data()!['firstName'] as String;
      _otherUserLastName = value.data()!['lastName'] as String;
      setState(() {
        _isLoading = false;
      });
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting message thread: $error')));
      Navigator.pop(context);
      return;
    });
  }

//  CLIENT DELETE FEATURES
//==========================================================================================================================
  void _deleteTrainer() async {
    try {
      //  Delete the message thread
      final messageThread = await FirebaseFirestore.instance
          .collection('messages')
          .where('trainerUID', isEqualTo: widget.otherPersonUID)
          .where('clientUID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (messageThread.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(messageThread.docs[0].id)
            .delete();
      } else {
        return;
      }

      //  Remove the trainer from the current user's data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'currentTrainer': '', 'isConfirmed': false});

      //  Remove the client from the trainer's current clients
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherPersonUID)
          .update({
        'currentClients':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });

      //  call the callback widget and return to the client home screen
      widget.onCallback!();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing trainer: $error')));
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to remove your trainer?'),
          actions: [
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _deleteTrainer();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
//==========================================================================================================================

//  SCHEDULE FUNCTIONS
//==========================================================================================================================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      year = picked.year;
      month = picked.month;
      day = picked.day;
      // ignore: use_build_context_synchronously
      _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    const TimeOfDay initialTime = TimeOfDay(hour: 7, minute: 0);
    const TimeOfDay lastTime = TimeOfDay(hour: 20, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.purple)),
            child: child!,
          );
        });
    if (picked != null && !_isTimeInRange(picked, initialTime, lastTime)) {
      // ignore: use_build_context_synchronously
      _showTimeOutOfRangeDialog(context);
    } else if (picked != null) {
      hour = picked.hour;
      minute = picked.minute;

      _setAppointmentFirebase(DateTime(year, month, day, hour, minute));
    }
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final currentTime = DateTime(2023, 1, 1, time.hour, time.minute);
    final startTime = DateTime(2023, 1, 1, start.hour, start.minute);
    final endTime = DateTime(2023, 1, 1, end.hour, end.minute);

    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  void _showTimeOutOfRangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Time Selection Error'),
          content: const Text('Please select a time between 7am and 8pm.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _setAppointmentFirebase(DateTime appointment) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      Map<String, int> appointmentDate = {
        'day': appointment.day,
        'month': appointment.month,
        'year': appointment.year,
        'hour': appointment.hour,
        'minute': appointment.minute
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherPersonUID)
          .update({'appointment': appointmentDate});

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully set appointment')));
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error setting gym appointment: ${error.toString()}')));
    }
  }

  //==========================================================================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$_otherUserFirstName $_otherUserLastName'),
          actions: widget.isClient
              ? [
                  IconButton(
                      onPressed: _showConfirmationDialog,
                      icon: const Icon(Icons.delete))
                ]
              : [
                  IconButton(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_month))
                ],
        ),
        body: switchedLoadingContainer(
            _isLoading,
            Column(children: [
              Expanded(
                  child: ChatMessages(
                otherUID: widget.otherPersonUID,
                isClient: widget.isClient,
              )),
              NewMessage(
                otherUID: widget.otherPersonUID,
                isClient: widget.isClient,
              )
            ])));
  }
}
