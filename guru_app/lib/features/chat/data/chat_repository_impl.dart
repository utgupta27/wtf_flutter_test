import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/chat/data/chat_repository.dart';

class HiveChatRepository implements ChatRepository {
  const HiveChatRepository(this._box);
  final Box<dynamic> _box;

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final all = _box.values
        .map((raw) => Message.fromMap(Map<String, dynamic>.from(raw as Map)))
        .where((m) => m.chatId == chatId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return all;
  }

  @override
  Future<void> saveMessage(Message message) async {
    await _box.put(message.id, message.toMap());
  }

  @override
  Future<void> updateStatus(String messageId, MessageStatus status) async {
    final raw = _box.get(messageId);
    if (raw == null) {
      return;
    }
    final msg = Message.fromMap(Map<String, dynamic>.from(raw as Map));
    await _box.put(messageId, msg.copyWith(status: status).toMap());
  }
}
