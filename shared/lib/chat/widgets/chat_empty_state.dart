import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';

/// Empty chat list with Say hi CTA.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.onSayHi,
    this.subtitle = 'Say hi to your trainer to get started',
  });

  final VoidCallback onSayHi;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: ChatTheme.memberBlue.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ChatTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ChatTheme.subtle, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSayHi,
              icon: const Icon(Icons.waving_hand_rounded),
              label: const Text('Say hi'),
            ),
          ],
        ),
      ),
    );
  }
}
