import 'package:shared/models/message.dart';

/// Local chat persistence (Hive-backed in apps).
abstract interface class ChatRepository {
  Future<List<Message>> getMessages(String chatId);
  Future<void> saveMessage(Message message);
  Future<void> updateStatus(String messageId, MessageStatus status);
}
