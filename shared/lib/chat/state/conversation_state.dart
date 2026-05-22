import 'package:shared/models/message.dart';

class ConversationState {
  const ConversationState({
    required this.messages,
    this.displayStart = 0,
    this.isPeerTyping = false,
    this.isSending = false,
    this.isLoadingHistory = false,
  });

  final List<Message> messages;
  final int displayStart;
  final bool isPeerTyping;
  final bool isSending;
  final bool isLoadingHistory;

  List<Message> get visibleMessages =>
      displayStart <= 0 ? messages : messages.sublist(displayStart);

  bool get hasOlderMessages => displayStart > 0;

  ConversationState copyWith({
    List<Message>? messages,
    int? displayStart,
    bool? isPeerTyping,
    bool? isSending,
    bool? isLoadingHistory,
  }) =>
      ConversationState(
        messages: messages ?? this.messages,
        displayStart: displayStart ?? this.displayStart,
        isPeerTyping: isPeerTyping ?? this.isPeerTyping,
        isSending: isSending ?? this.isSending,
        isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      );
}

int initialConversationDisplayStart(int messageCount) {
  const initialWindow = 25;
  if (messageCount <= initialWindow) {
    return 0;
  }
  return messageCount - initialWindow;
}
