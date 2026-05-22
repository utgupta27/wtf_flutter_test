import 'package:intl/intl.dart';

/// Formats chat list timestamps ("5m ago", today HH:mm, etc.).
String formatChatListTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return m <= 0 ? 'Just now' : '${m}m ago';
  }
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return DateFormat('HH:mm').format(dt);
  }
  if (dt.year == now.year) {
    return DateFormat('d MMM').format(dt);
  }
  return DateFormat('d/M/yy').format(dt);
}
