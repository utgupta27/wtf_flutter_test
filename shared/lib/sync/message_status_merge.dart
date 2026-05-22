import 'package:shared/models/message.dart';

/// Ordinal merge so read receipts never regress on pull.
MessageStatus mergeMessageStatus(MessageStatus current, MessageStatus incoming) {
  if (current.index >= incoming.index) {
    return current;
  }
  return incoming;
}
