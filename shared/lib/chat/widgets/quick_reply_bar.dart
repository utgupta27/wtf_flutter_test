import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';

/// Horizontally scrollable quick-reply chips.
class ChatQuickReplyBar extends StatelessWidget {
  const ChatQuickReplyBar({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final void Function(String text) onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final label = suggestions[index];
            return ActionChip(
              label: Text(label),
              labelStyle: const TextStyle(fontSize: 13),
              backgroundColor: ChatTheme.surface,
              side: BorderSide(
                color: ChatTheme.memberBlue.withValues(alpha: 0.25),
              ),
              onPressed: () => onTap(label),
            );
          },
        ),
      ),
    );
  }
}
