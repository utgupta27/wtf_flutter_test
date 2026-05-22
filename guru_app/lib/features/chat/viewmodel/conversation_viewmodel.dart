import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

import 'package:guru_app/features/chat/data/chat_repository.dart';
import 'package:guru_app/providers/repository_providers.dart';

class ConversationState {
  const ConversationState({
    required this.messages,
    this.isTyping = false,
    this.isSending = false,
  });

  final List<Message> messages;
  final bool isTyping;
  final bool isSending;

  ConversationState copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? isSending,
  }) =>
      ConversationState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        isSending: isSending ?? this.isSending,
      );
}

final conversationViewModelProvider = AsyncNotifierProviderFamily<
    ConversationViewModel, ConversationState, String>(
  ConversationViewModel.new,
);

class ConversationViewModel
    extends FamilyAsyncNotifier<ConversationState, String> {
  late final ChatRepository _repo;
  late final String _chatId;

  static const _uuid = Uuid();

  @override
  Future<ConversationState> build(String chatId) async {
    _chatId = chatId;
    _repo = ref.read(chatRepositoryProvider);
    final messages = await _repo.getMessages(chatId);
    return ConversationState(messages: messages);
  }

  Future<void> send({
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    final current = state.valueOrNull ?? const ConversationState(messages: []);
    final optimistic = Message(
      id: _uuid.v4(),
      chatId: _chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
    );

    // Optimistic update
    state = AsyncData(current.copyWith(
      messages: [...current.messages, optimistic],
      isSending: true,
    ));

    await _repo.saveMessage(optimistic);

    // Simulate network delay then mark as sent
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _repo.updateStatus(optimistic.id, MessageStatus.sent);

    final updated = await _repo.getMessages(_chatId);
    state = AsyncData(current.copyWith(messages: updated, isSending: false));
  }

  void setTyping({required bool value}) {
    final current = state.valueOrNull ?? const ConversationState(messages: []);
    state = AsyncData(current.copyWith(isTyping: value));
  }
}
