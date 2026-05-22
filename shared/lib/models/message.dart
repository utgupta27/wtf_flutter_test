import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  read,
}

@HiveType(typeId: 2)
class Message extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String receiverId;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final MessageStatus status;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sending,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
  }) =>
      Message(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [id, chatId, senderId, receiverId, text, createdAt, status];
}
