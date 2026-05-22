import 'package:shared/observability/log_tag.dart';

/// A single in-memory log line shown in the DevPanel.
class LogEntry {
  const LogEntry({
    required this.tag,
    required this.message,
    required this.at,
    this.level = LogLevel.info,
    this.detail,
  });

  final LogTag tag;
  final String message;
  final DateTime at;
  final LogLevel level;
  final String? detail;

  String get prefix => logTagPrefix(tag);

  String get displayLine {
    final buffer = StringBuffer('$prefix $message');
    if (detail != null && detail!.isNotEmpty) {
      buffer.write(' | $detail');
    }
    return buffer.toString();
  }
}

enum LogLevel { info, warning, error }
