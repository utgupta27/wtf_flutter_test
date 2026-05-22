import 'package:flutter_test/flutter_test.dart';
import 'package:shared/chat/logic/unread_counter.dart';
import 'package:shared/constants/sync_constants.dart';
import 'package:shared/models/message.dart';

void main() {
  test('countUnreadMessages ignores own and system messages', () {
    final count = countUnreadMessages(
      [
        Message(
          id: '1',
          chatId: 'c',
          senderId: SyncConstants.trainerId,
          receiverId: SyncConstants.memberId,
          text: 'Hi',
          createdAt: DateTime.now(),
        ),
        Message(
          id: '2',
          chatId: 'c',
          senderId: SyncConstants.memberId,
          receiverId: SyncConstants.trainerId,
          text: 'Hey',
          createdAt: DateTime.now(),
          status: MessageStatus.read,
        ),
      ],
      SyncConstants.memberId,
    );
    expect(count, 1);
  });
}
