import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';
import 'package:shared/chat/data/chat_preview.dart';
import 'package:shared/chat/logic/chat_time_format.dart';
import 'package:shared/chat/widgets/chat_red_dot.dart';
import 'package:shared/chat/widgets/unread_badge.dart';

/// Single row in the chat list.
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.preview,
    required this.onTap,
    required this.peerColor,
  });

  final ChatPreview preview;
  final VoidCallback onTap;
  final Color peerColor;

  @override
  Widget build(BuildContext context) {
    final hasUnread = preview.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ChatRedDotBadge(
              show: hasUnread,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: peerColor.withValues(alpha: 0.15),
                child: Text(
                  preview.otherUserName.isNotEmpty
                      ? preview.otherUserName[0]
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: peerColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.otherUserName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w500,
                            color: ChatTheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        formatChatListTime(preview.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? ChatTheme.memberBlue
                              : ChatTheme.subtle,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? ChatTheme.onSurface
                                : ChatTheme.subtle,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        ChatUnreadBadge(count: preview.unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
