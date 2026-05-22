import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/chat/data/chat_repository.dart';

class HiveChatRepository implements ChatRepository {
  HiveChatRepository(this._box);
  final Box _box;

  @override
  Future<List<Message>> getMessages(String chatId) async =>
      _box.values
          .cast<Message>()
          .where((m) => m.chatId == chatId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<void> saveMessage(Message message) async =>
      _box.put(message.id, message);

  @override
  Future<void> updateStatus(String messageId, MessageStatus status) async {
    final existing = _box.get(messageId) as Message?;
    if (existing != null) {
      await _box.put(messageId, existing.copyWith(status: status));
    }
  }
}
