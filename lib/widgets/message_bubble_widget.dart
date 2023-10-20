import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = true,
        userImage = null,
        username = null;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // First messages in the sequence provide a visual buffer at the top.
              if (isFirstInSequence) const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: isMe ? Colors.grey[300] : CustomColors.purpleSnail,
                  borderRadius: BorderRadius.only(
                    topLeft: !isMe && isFirstInSequence
                        ? Radius.zero
                        : const Radius.circular(12),
                    topRight: isMe && isFirstInSequence
                        ? Radius.zero
                        : const Radius.circular(12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  message,
                  style: GoogleFonts.nunitoSans(
                      textStyle: TextStyle(
                    height: 1.3,
                    color:
                        isMe ? Colors.black87 : theme.colorScheme.onSecondary,
                  )),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
