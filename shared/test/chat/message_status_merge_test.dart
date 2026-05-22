import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/message.dart';
import 'package:shared/sync/message_status_merge.dart';

void main() {
  test('mergeMessageStatus keeps higher ordinal', () {
    expect(
      mergeMessageStatus(MessageStatus.sent, MessageStatus.read),
      MessageStatus.read,
    );
    expect(
      mergeMessageStatus(MessageStatus.read, MessageStatus.sent),
      MessageStatus.read,
    );
  });
}
