import 'package:shared/models/message.dart';

/// Count inbound messages not yet read by [localUserId].
int countUnreadMessages(List<Message> messages, String localUserId) {
  return messages
      .where(
        (m) =>
            m.senderId != localUserId &&
            m.senderId != 'system' &&
            m.status != MessageStatus.read,
      )
      .length;
}
