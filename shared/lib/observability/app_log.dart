import 'package:flutter/foundation.dart';

import 'package:shared/observability/log_buffer.dart';
import 'package:shared/observability/log_entry.dart';
import 'package:shared/observability/log_tag.dart';

/// Structured logger: tags, ring buffer, and console output in debug.
abstract class AppLog {
  static void i(
    LogTag tag,
    String message, {
    String? detail,
  }) {
    _write(tag, message, level: LogLevel.info, detail: detail);
  }

  static void w(
    LogTag tag,
    String message, {
    String? detail,
    Object? error,
  }) {
    final mergedDetail = _mergeDetail(detail, error);
    _write(tag, message, level: LogLevel.warning, detail: mergedDetail);
  }

  static void e(
    LogTag tag,
    String message, {
    String? detail,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final mergedDetail = _mergeDetail(detail, error, stackTrace);
    _write(tag, message, level: LogLevel.error, detail: mergedDetail);
  }

  static void _write(
    LogTag tag,
    String message, {
    required LogLevel level,
    String? detail,
  }) {
    LogBuffer.instance.add(
      LogEntry(
        tag: tag,
        message: message,
        at: DateTime.now(),
        level: level,
        detail: detail,
      ),
    );
    if (kDebugMode) {
      debugPrint('${logTagPrefix(tag)} $message${detail != null ? ' | $detail' : ''}');
    }
  }

  static String? _mergeDetail(
    String? detail,
    Object? error, [
    StackTrace? stackTrace,
  ]) {
    final parts = <String>[];
    if (detail != null && detail.isNotEmpty) {
      parts.add(detail);
    }
    if (error != null) {
      parts.add(error.toString());
    }
    if (stackTrace != null) {
      parts.add(stackTrace.toString());
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' | ');
  }
}
