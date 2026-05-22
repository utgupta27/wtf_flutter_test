import 'package:flutter_test/flutter_test.dart';
import 'package:shared/chat/logic/quick_reply_suggestions.dart';
import 'package:shared/constants/sync_constants.dart';
import 'package:shared/models/message.dart';

void main() {
  group('suggestQuickReplies', () {
    test('returns starter chips when thread is empty', () {
      final chips = suggestQuickReplies(
        [],
        peerUserId: SyncConstants.trainerId,
      );
      expect(chips, contains('Hey! Ready to train?'));
      expect(chips.length, lessThanOrEqualTo(4));
    });

    test('prioritizes plan chip when peer mentions plan', () {
      final chips = suggestQuickReplies(
        [
          Message(
            id: '1',
            chatId: 'c',
            senderId: SyncConstants.trainerId,
            receiverId: SyncConstants.memberId,
            text: 'Send your workout plan',
            createdAt: DateTime.now(),
          ),
        ],
        peerUserId: SyncConstants.trainerId,
      );
      expect(chips.first, 'Share plan?');
    });
  });
}
