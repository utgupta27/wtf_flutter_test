import 'package:flutter/foundation.dart';

import 'package:shared/observability/log_entry.dart';

/// Ring buffer holding the last [capacity] structured log entries.
class LogBuffer extends ChangeNotifier {
  LogBuffer._();
  static final LogBuffer instance = LogBuffer._();

  static const int capacity = 20;

  final List<LogEntry> _entries = <LogEntry>[];

  /// Newest-first snapshot for the DevPanel.
  List<LogEntry> get entries => List<LogEntry>.unmodifiable(_entries.reversed);

  void add(LogEntry entry) {
    _entries.add(entry);
    if (_entries.length > capacity) {
      _entries.removeAt(0);
    }
    notifyListeners();
  }

  /// Clears all entries (tests / manual reset).
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
