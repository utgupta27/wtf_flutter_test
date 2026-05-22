import 'package:shared/models/typing_presence.dart';

extension TypingPresenceJson on TypingPresence {
  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'userId': userId,
        'isTyping': isTyping,
        'at': at.toIso8601String(),
      };

  static TypingPresence fromJson(Map<String, dynamic> json) => TypingPresence(
        chatId: json['chatId'] as String,
        userId: json['userId'] as String,
        isTyping: json['isTyping'] as bool? ?? false,
        at: DateTime.parse(json['at'] as String),
      );
}
