import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final String otherUID;
  final bool isClient;
  const NewMessage({super.key, required this.otherUID, required this.isClient});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final checkMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('trainerUID',
              isEqualTo: widget.isClient ? widget.otherUID : user.uid)
          .where('clientUID',
              isEqualTo: widget.isClient ? user.uid : widget.otherUID)
          .get();
      print('aaa');
      final chatDocument = checkMessages.docs.first;
      print('lll');
      final messageThreadCollection =
          chatDocument.reference.collection('messageThread');
      print('bbb');
      await messageThreadCollection.add({
        'sender': user.uid,
        'dateTimeSent': DateTime.now(),
        'messageContent': enteredMessage
      });
      return;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Sending Message: $error')));
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
