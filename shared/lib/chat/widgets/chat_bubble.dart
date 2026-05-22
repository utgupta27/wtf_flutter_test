import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/config/chat_theme.dart';
import 'package:shared/chat/logic/message_attachments.dart';
import 'package:shared/models/message.dart';

/// Role-colored message bubble with optional image and status ticks.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.config,
  });

  final Message message;
  final ChatAppConfig config;

  @override
  Widget build(BuildContext context) {
    if (message.senderId == 'system') {
      return ChatSystemBubble(text: message.text);
    }

    final isMine = config.isMine(message.senderId);
    final bubbleColor = isMine ? config.myBubbleColor : config.peerBubbleColor;
    final letter = config.peerAvatarLetter ?? '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: config.peerBubbleColor.withValues(alpha: 0.15),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 12,
                  color: config.peerBubbleColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isImageMessage(message))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imageMessagePath(message)),
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image_outlined,
                                color: Colors.white70),
                      ),
                    )
                  else
                    Text(
                      message.text,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        ChatStatusTick(status: message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatSystemBubble extends StatelessWidget {
  const ChatSystemBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: ChatTheme.subtle),
          ),
        ),
      ),
    );
  }
}

class ChatStatusTick extends StatelessWidget {
  const ChatStatusTick({super.key, required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded,
            size: 12, color: Colors.white70);
      case MessageStatus.sent:
        return const Icon(Icons.done_rounded, size: 14, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: Colors.white);
    }
  }
}
