import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessco/utils/firebase_messaging_util.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final List<dynamic> pushTokens;
  final String otherName;
  final String otherUID;
  final bool isClient;
  const NewMessage(
      {super.key,
      required this.pushTokens,
      required this.otherName,
      required this.otherUID,
      required this.isClient});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();

    //  If the current user is a client, we will get the trainer's data and check if their account has been deleted by the admin
    if (widget.isClient) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUID)
          .get()
          .then((value) {
        if (value.data()!['isDeleted'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('This trainer has been deleted by the admin')));

          _deleteTrainer();
          Navigator.pop(context);
          return;
        }
      });
    }
    //  If the current user is a trainer, we will get the client's current data and check if we are still their current trainer
    else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUID)
          .get()
          .then((value) {
        if (value.data()!['currentTrainer'] !=
            FirebaseAuth.instance.currentUser!.uid) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Your client has removed you as their trainer')));
          Navigator.pop(context);
          return;
        }
      });
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final checkMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('trainerUID',
              isEqualTo: widget.isClient ? widget.otherUID : user.uid)
          .where('clientUID',
              isEqualTo: widget.isClient ? user.uid : widget.otherUID)
          .get();
      final chatDocument = checkMessages.docs.first;
      final messageThreadCollection =
          chatDocument.reference.collection('messageThread');
      await messageThreadCollection.add({
        'sender': user.uid,
        'dateTimeSent': DateTime.now(),
        'messageContent': enteredMessage
      });
      for (var token in widget.pushTokens) {
        FirebaseMessagingUtil.sendMessageSentNotif(
            token, widget.otherName, enteredMessage);
      }
      return;
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error Sending Message: $error')));
    }
  }

  void _deleteTrainer() async {
    try {
      //  Delete the message thread
      final messageThread = await FirebaseFirestore.instance
          .collection('messages')
          .where('trainerUID', isEqualTo: widget.otherUID)
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
          .doc(widget.otherUID)
          .update({
        'currentClients':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing trainer: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 1, right: 14),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          decoration: const InputDecoration(labelText: 'Send a message...'),
        )),
        IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send))
      ]),
    );
  }
}
