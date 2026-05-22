import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/config/chat_theme.dart';

/// Message composer with attach and send.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.config,
    required this.onSend,
    required this.onChanged,
    required this.onAttach,
  });

  final TextEditingController controller;
  final ChatAppConfig config;
  final VoidCallback onSend;
  final void Function(String text) onChanged;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Attach image',
            onPressed: onAttach,
            icon: Icon(Icons.image_outlined, color: config.myBubbleColor),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Message ${config.peerDisplayName}...',
                hintStyle: const TextStyle(color: ChatTheme.subtle),
                filled: true,
                fillColor: ChatTheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: config.myBubbleColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
