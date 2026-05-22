import 'package:shared/models/message.dart';

extension MessageJson on Message {
  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  static Message fromJson(Map<String, dynamic> json) {
    final statusName = json['status'];
    MessageStatus status;
    if (statusName is String) {
      status = MessageStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => MessageStatus.sent,
      );
    } else if (statusName is int) {
      status = MessageStatus.values[statusName];
    } else {
      status = MessageStatus.sent;
    }
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: status,
    );
  }
}
