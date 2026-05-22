import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/data/chat_preview.dart';
import 'package:shared/chat/logic/message_attachments.dart';
import 'package:shared/chat/logic/unread_counter.dart';
import 'package:shared/chat/state/chat_providers.dart';
import 'package:shared/constants/sync_constants.dart';
final chatListViewModelProvider =
    AsyncNotifierProvider.family<ChatListViewModel, List<ChatPreview>, ChatAppConfig>(
  ChatListViewModel.new,
);

class ChatListViewModel extends FamilyAsyncNotifier<List<ChatPreview>, ChatAppConfig> {
  @override
  Future<List<ChatPreview>> build(ChatAppConfig config) async {
    ref.listen(sharedSyncTickProvider, (_, __) {
      ref.invalidateSelf();
    });
    return _load(config);
  }

  Future<List<ChatPreview>> _load(ChatAppConfig config) async {
    final repo = ref.read(sharedChatRepositoryProvider);
    const chatId = SyncConstants.defaultChatId;
    final messages = await repo.getMessages(chatId);

    if (messages.isEmpty) {
      return [];
    }

    final last = messages.last;
    final unread = countUnreadMessages(messages, config.localUserId);

    return [
      ChatPreview(
        chatId: chatId,
        otherUserId: config.peerUserId,
        otherUserName: config.peerDisplayName,
        lastMessage: isImageMessage(last) ? '📷 Photo' : last.text,
        lastMessageAt: last.createdAt,
        unreadCount: unread,
        lastStatus: last.status,
      ),
    ];
  }

  Future<void> refresh() async {
    final config = arg;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(config));
  }
}
