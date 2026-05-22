import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class ConversationState {
  const ConversationState({
    this.messages = const [],
    this.isSending = false,
  });

  final List<Message> messages;
  final bool isSending;

  ConversationState copyWith({List<Message>? messages, bool? isSending}) =>
      ConversationState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
      );
}

class ConversationViewModel
    extends FamilyAsyncNotifier<ConversationState, String> {
  static const _chatId = 'chat-dk-aarav';

  @override
  Future<ConversationState> build(String chatId) async {
    final messages =
        await ref.read(chatRepositoryProvider).getMessages(chatId);
    return ConversationState(messages: messages);
  }

  Future<void> send(String text) async {
    final current = state.value;
    if (current == null || text.trim().isEmpty) return;

    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatId,
      senderId: 'trainer-aarav-001',
      receiverId: 'member-dk-001',
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data(
      current.copyWith(
        messages: [...current.messages, msg],
        isSending: true,
      ),
    );

    await ref.read(chatRepositoryProvider).saveMessage(msg);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await ref.read(chatRepositoryProvider).updateStatus(msg.id, MessageStatus.sent);

    final updated = msg.copyWith(status: MessageStatus.sent);
    final msgs = state.value!.messages
        .map((m) => m.id == msg.id ? updated : m)
        .toList();
    state = AsyncValue.data(state.value!.copyWith(messages: msgs, isSending: false));
  }
}

final conversationViewModelProvider = AsyncNotifierProviderFamily<
    ConversationViewModel, ConversationState, String>(
  ConversationViewModel.new,
);
