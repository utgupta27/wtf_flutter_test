import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/logic/message_attachments.dart';
import 'package:shared/chat/state/chat_providers.dart';
import 'package:shared/chat/state/conversation_state.dart';
import 'package:shared/chat/state/peer_typing_provider.dart';
import 'package:shared/models/message.dart';
import 'package:shared/observability/app_log.dart';
import 'package:shared/observability/log_tag.dart';
import 'package:shared/sync/message_status_merge.dart';
import 'package:uuid/uuid.dart';

class ConversationParams {
  const ConversationParams({required this.chatId, required this.config});
  final String chatId;
  final ChatAppConfig config;

  @override
  bool operator ==(Object other) =>
      other is ConversationParams &&
      chatId == other.chatId &&
      config.role == other.config.role;

  @override
  int get hashCode => Object.hash(chatId, config.role);
}

final conversationViewModelProvider = AsyncNotifierProviderFamily<
    ConversationViewModel, ConversationState, ConversationParams>(
  ConversationViewModel.new,
);

class ConversationViewModel
    extends FamilyAsyncNotifier<ConversationState, ConversationParams> {
  static const _uuid = Uuid();
  Timer? _typingStopTimer;

  @override
  Future<ConversationState> build(ConversationParams params) async {
    ref.listen(sharedSyncTickProvider, (_, __) => unawaited(_reload()));
    ref.listen(peerTypingProvider(peerTypingParams(params.config, params.chatId)),
        (_, next) {
      final current = state.valueOrNull;
      if (current != null && current.isPeerTyping != next) {
        state = AsyncData(current.copyWith(isPeerTyping: next));
      }
    });

    final messages =
        await ref.read(sharedChatRepositoryProvider).getMessages(params.chatId);
    await _markInboundRead(messages, params.config);

    final isTyping = ref.read(
      peerTypingProvider(peerTypingParams(params.config, params.chatId)),
    );

    return ConversationState(
      messages: messages,
      displayStart: initialConversationDisplayStart(messages.length),
      isPeerTyping: isTyping,
    );
  }

  Future<void> loadOlderMessages() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasOlderMessages) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingHistory: true));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    const pageSize = 20;
    final nextStart =
        (current.displayStart - pageSize).clamp(0, current.displayStart);
    state = AsyncData(
      current.copyWith(
        displayStart: nextStart,
        isLoadingHistory: false,
      ),
    );
  }

  void onComposerChanged(String text) {
    final params = arg;
    final sync = ref.read(sharedSyncServiceProvider);
    _typingStopTimer?.cancel();
    if (text.trim().isEmpty) {
      sync.enqueueTyping(
        chatId: params.chatId,
        userId: params.config.localUserId,
        isTyping: false,
      );
      return;
    }
    sync.enqueueTyping(
      chatId: params.chatId,
      userId: params.config.localUserId,
      isTyping: true,
    );
    _typingStopTimer = Timer(const Duration(milliseconds: 1200), () {
      sync.enqueueTyping(
        chatId: params.chatId,
        userId: params.config.localUserId,
        isTyping: false,
      );
    });
  }

  void stopTypingSignal() {
    final params = arg;
    _typingStopTimer?.cancel();
    ref.read(sharedSyncServiceProvider).enqueueTyping(
          chatId: params.chatId,
          userId: params.config.localUserId,
          isTyping: false,
        );
  }

  Future<void> _reload() async {
    final params = arg;
    final repo = ref.read(sharedChatRepositoryProvider);
    final messages = await repo.getMessages(params.chatId);
    await _markInboundRead(messages, params.config);
    final prev = state.valueOrNull;
    final isTyping = ref.read(
      peerTypingProvider(peerTypingParams(params.config, params.chatId)),
    );
    state = AsyncData(
      ConversationState(
        messages: messages,
        displayStart:
            prev?.displayStart ?? initialConversationDisplayStart(messages.length),
        isPeerTyping: isTyping,
        isSending: prev?.isSending ?? false,
      ),
    );
  }

  Future<void> _markInboundRead(
    List<Message> messages,
    ChatAppConfig config,
  ) async {
    final repo = ref.read(sharedChatRepositoryProvider);
    final sync = ref.read(sharedSyncServiceProvider);
    for (final m in messages) {
      if (!config.isMine(m.senderId) &&
          m.senderId != 'system' &&
          m.status != MessageStatus.read) {
        await repo.updateStatus(m.id, MessageStatus.read);
        sync.enqueueMessageStatus(m.id, MessageStatus.read);
      }
    }
  }

  Future<void> send(String text) async {
    final params = arg;
    final repo = ref.read(sharedChatRepositoryProvider);
    final sync = ref.read(sharedSyncServiceProvider);
    final current = state.valueOrNull ?? const ConversationState(messages: []);

    stopTypingSignal();
    AppLog.i(LogTag.chat, 'send message', detail: 'chatId=${params.chatId}');

    final optimistic = Message(
      id: _uuid.v4(),
      chatId: params.chatId,
      senderId: params.config.localUserId,
      receiverId: params.config.peerUserId,
      text: text,
      createdAt: DateTime.now(),
    );

    state = AsyncData(
      current.copyWith(
        messages: [...current.messages, optimistic],
        isSending: true,
      ),
    );

    await repo.saveMessage(optimistic);
    sync.enqueueMessage(optimistic);

    try {
      await sync.syncMessagesNow();
    } catch (e, st) {
      AppLog.e(LogTag.chat, 'send sync failed', error: e, stackTrace: st);
    }

    final updated = await repo.getMessages(params.chatId);
    final synced = updated.firstWhere(
      (m) => m.id == optimistic.id,
      orElse: () => optimistic.copyWith(status: MessageStatus.sent),
    );
    state = AsyncData(
      ConversationState(
        messages: updated
            .map(
              (m) => m.id == optimistic.id
                  ? m.copyWith(
                      status: mergeMessageStatus(
                        optimistic.status,
                        synced.status,
                      ),
                    )
                  : m,
            )
            .toList(),
        displayStart: current.displayStart,
        isPeerTyping: ref.read(
          peerTypingProvider(peerTypingParams(params.config, params.chatId)),
        ),
        isSending: false,
      ),
    );
    AppLog.i(LogTag.chat, 'message sent', detail: 'id=${optimistic.id}');
  }

  Future<void> sendImage(String filePath) async {
    await send(imageMessageText(filePath));
  }
}
