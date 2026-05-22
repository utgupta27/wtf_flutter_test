import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class ChatPreview {
  const ChatPreview({
    required this.chatId,
    required this.memberName,
    required this.lastMessage,
    required this.lastTime,
    required this.hasUnread,
  });

  final String chatId;
  final String memberName;
  final String lastMessage;
  final DateTime lastTime;
  final bool hasUnread;
}

class ChatListViewModel extends AsyncNotifier<List<ChatPreview>> {
  static const _chatId = 'chat-dk-aarav';

  @override
  Future<List<ChatPreview>> build() async => _load();

  Future<List<ChatPreview>> _load() async {
    final messages = await ref.read(chatRepositoryProvider).getMessages(_chatId);
    if (messages.isEmpty) return [];

    final last = messages.last;
    // Unread = member message that is not yet read by trainer
    final hasUnread = messages.any(
      (m) => m.senderId == 'member-dk-001' && m.status != MessageStatus.read,
    );

    return [
      ChatPreview(
        chatId: _chatId,
        memberName: 'DK',
        lastMessage: last.text,
        lastTime: last.createdAt,
        hasUnread: hasUnread,
      ),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final chatListViewModelProvider =
    AsyncNotifierProvider<ChatListViewModel, List<ChatPreview>>(
  ChatListViewModel.new,
);
