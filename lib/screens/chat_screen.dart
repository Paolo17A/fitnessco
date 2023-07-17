// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/screens/client_workout_screen.dart';
import 'package:fitnessco/utils/firebase_util.dart';
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

  void _goToClientWorkoutsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ClientWorkoutsScreen(clientUID: widget.otherPersonUID),
      ),
    );
  }

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
                    onPressed: () => _goToClientWorkoutsScreen(context),
                    icon: const Icon(Icons.fitness_center_rounded))
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                  child: ChatMessages(
                otherUID: widget.otherPersonUID,
                isClient: widget.isClient,
              )),
              NewMessage(
                otherUID: widget.otherPersonUID,
                isClient: widget.isClient,
              )
            ]),
    );
  }
}
