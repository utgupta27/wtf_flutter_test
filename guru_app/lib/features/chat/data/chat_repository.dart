import 'package:shared/shared.dart';

abstract interface class ChatRepository {
  Future<List<Message>> getMessages(String chatId);
  Future<void> saveMessage(Message message);
  Future<void> updateStatus(String messageId, MessageStatus status);
}
