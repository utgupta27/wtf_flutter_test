import 'package:equatable/equatable.dart';

/// Ephemeral typing state synced via node hub.
class TypingPresence extends Equatable {
  const TypingPresence({
    required this.chatId,
    required this.userId,
    required this.isTyping,
    required this.at,
  });

  final String chatId;
  final String userId;
  final bool isTyping;
  final DateTime at;

  @override
  List<Object?> get props => [chatId, userId, isTyping, at];
}
