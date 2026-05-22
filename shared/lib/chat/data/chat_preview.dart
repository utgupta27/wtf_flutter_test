import 'package:shared/models/message.dart';

/// Row model for chat list screens.
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
