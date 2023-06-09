import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatroom')),
      body: const Center(
          child: Text(
        'THIS IS THE CHATROOM',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
      )),
    );
  }
}
