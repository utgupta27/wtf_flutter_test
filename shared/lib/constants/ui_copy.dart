import 'package:intl/intl.dart';

/// Canonical UI strings for chat and call flows (use as-is).
class UiCopy {
  UiCopy._();

  static const emptyChat = 'No messages yet. Start the conversation.';

  static const callRequestedWaiting =
      'Call requested. Waiting for trainer approval.';

  static const joinPrompt = 'Ready to join? Check mic and camera.';

  static const sessionEnded = 'Session saved to your logs.';

  static String callApprovedFor(DateTime scheduledFor) {
    final date = DateFormat('EEE, MMM d').format(scheduledFor);
    final time = DateFormat('h:mm a').format(scheduledFor);
    return 'Call approved for $date $time.';
  }

  static String callDeclined(String reason) =>
      'Call request declined. Reason: $reason.';
}
