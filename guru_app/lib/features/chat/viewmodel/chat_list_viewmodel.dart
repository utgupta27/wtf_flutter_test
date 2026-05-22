import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/chat/chat_list_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';

final chatListViewModelProvider =
    AsyncNotifierProvider<ChatListViewModel, List<ChatPreview>>(
  ChatListViewModel.new,
);

class ChatListViewModel extends AsyncNotifier<List<ChatPreview>> {
  @override
  Future<List<ChatPreview>> build() async {
    final repo = ref.read(chatRepositoryProvider);
    // For seed data: one conversation between DK and Aarav
    const chatId = 'chat-dk-aarav';
    final messages = await repo.getMessages(chatId);

    if (messages.isEmpty) {
      return [];
    }

    final last = messages.last;
    final unread = messages
        .where((m) =>
            m.senderId != SeedUsers.member.id &&
            m.status != MessageStatus.read)
        .length;

    return [
      ChatPreview(
        chatId: chatId,
        otherUserId: SeedUsers.trainer.id,
        otherUserName: SeedUsers.trainer.name,
        lastMessage: last.text,
        lastMessageAt: last.createdAt,
        unreadCount: unread,
        lastStatus: last.status,
      ),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
