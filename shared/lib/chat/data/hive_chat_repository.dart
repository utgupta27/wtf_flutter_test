import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/chat/data/chat_repository.dart';
import 'package:shared/models/message.dart';

/// Hive implementation shared by guru and trainer apps.
class HiveChatRepository implements ChatRepository {
  HiveChatRepository(this._box);
  final Box<dynamic> _box;

  static Message _parseMessage(dynamic raw) {
    if (raw is Message) {
      return raw;
    }
    return Message.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final all = _box.values
        .map(_parseMessage)
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
    final msg = _parseMessage(raw);
    await _box.put(messageId, msg.copyWith(status: status).toMap());
  }
}
