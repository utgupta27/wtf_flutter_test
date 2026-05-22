import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/features/chat/viewmodel/chat_list_viewmodel.dart';

class ChatPreview {
  const ChatPreview({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.lastStatus,
  });

  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final MessageStatus lastStatus;
}

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Chats')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (conversations) => conversations.isEmpty
            ? const Center(
                child: Text(
                  'No conversations yet',
                  style: TextStyle(color: AppColors.subtle, fontSize: 15),
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(chatListViewModelProvider.notifier).refresh(),
                child: ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) => ChatListTile(
                    preview: conversations[index],
                    onTap: () =>
                        context.push('/chat/${conversations[index].chatId}'),
                  ),
                ),
              ),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.preview, required this.onTap});

  final ChatPreview preview;
  final VoidCallback onTap;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('HH:mm').format(dt);
    }
    if (dt.year == now.year) {
      return DateFormat('d MMM').format(dt);
    }
    return DateFormat('d/M/yy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = preview.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  AppColors.trainerPrimary.withValues(alpha: 0.15),
              child: Text(
                preview.otherUserName[0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.trainerPrimary,
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
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(preview.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              hasUnread ? AppColors.primary : AppColors.subtle,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
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
                                ? AppColors.onSurface
                                : AppColors.subtle,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasUnread) UnreadBadge(count: preview.unreadCount),
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

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
