import 'package:shared/models/message.dart';

/// Context-aware quick reply chips.
List<String> suggestQuickReplies(
  List<Message> messages, {
  required String peerUserId,
}) {
  const defaults = ['Got it 👍', 'Can we talk at 6?', 'Share plan?'];
  final ordered = <String>[];

  final peerMessages =
      messages.where((m) => m.senderId == peerUserId).toList();
  final lastInbound = peerMessages.isEmpty ? null : peerMessages.last;
  final lastText = lastInbound?.text.toLowerCase() ?? '';

  if (lastText.contains('plan') ||
      lastText.contains('workout') ||
      lastText.contains('program') ||
      lastText.contains('routine')) {
    ordered.add('Share plan?');
    ordered.add('I\'ll send my log tonight');
  }

  if (lastText.contains('time') ||
      lastText.contains('when') ||
      lastText.contains('schedule') ||
      lastText.contains('call') ||
      lastText.contains('meet')) {
    ordered.add(_suggestCallTime());
    ordered.add('Got it 👍');
  }

  if (lastText.contains('?') ||
      lastText.contains('let me know') ||
      lastText.contains('confirm') ||
      lastText.contains('ok')) {
    ordered.add('Got it 👍');
    ordered.add('Sounds good!');
  }

  if (lastText.contains('sorry') || lastText.contains('delay')) {
    ordered.add('No worries 👍');
  }

  if (lastText.contains('great') ||
      lastText.contains('good job') ||
      lastText.contains('well done')) {
    ordered.add('Thanks! 🙏');
  }

  final hour = DateTime.now().hour;
  if (hour >= 15 && hour < 19 && !ordered.contains('Can we talk at 6?')) {
    ordered.add('Can we talk at 6?');
  }

  if (messages.isEmpty) {
    return ['Hey! Ready to train?', 'Can we talk at 6?', 'Share plan?'];
  }

  for (final chip in [...ordered, ...defaults]) {
    if (!ordered.contains(chip)) {
      ordered.add(chip);
    }
    if (ordered.length >= 4) {
      break;
    }
  }

  return ordered.take(4).toList();
}

String _suggestCallTime() {
  final now = DateTime.now();
  if (now.hour < 16) {
    return 'Can we talk at 6?';
  }
  if (now.hour < 20) {
    return 'Free in 30 mins?';
  }
  return 'Tomorrow morning works?';
}
