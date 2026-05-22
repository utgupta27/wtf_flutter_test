import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';

/// Unread count pill for chat list rows.
class ChatUnreadBadge extends StatelessWidget {
  const ChatUnreadBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ChatTheme.trainerRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
