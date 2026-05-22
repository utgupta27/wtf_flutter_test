import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared/observability/dev_context.dart';
import 'package:shared/observability/log_tag.dart';

/// User-facing errors and info via Snackbars with optional copy-to-clipboard.
abstract class AppErrorSurface {
  static const String copyActionLabel = 'Copy error';

  /// Shows an error snackbar with human copy and a Copy error action.
  static void showError(
    BuildContext context, {
    required String userMessage,
    required String technicalDetail,
    LogTag? tag,
  }) {
    final payload = _formatCopyPayload(
      userMessage: userMessage,
      technicalDetail: technicalDetail,
      tag: tag,
    );
    _showSnack(
      context,
      content: Text(userMessage),
      actionLabel: copyActionLabel,
      onAction: () => _copy(payload),
    );
  }

  /// Shows an error using [ScaffoldMessengerState] (no [BuildContext]).
  static void showErrorWithMessenger(
    ScaffoldMessengerState messenger, {
    required String userMessage,
    required String technicalDetail,
    LogTag? tag,
  }) {
    final payload = _formatCopyPayload(
      userMessage: userMessage,
      technicalDetail: technicalDetail,
      tag: tag,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(userMessage),
        action: SnackBarAction(
          label: copyActionLabel,
          onPressed: () => _copy(payload),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  /// Non-error informational snackbar (no copy action).
  static void showInfo(BuildContext context, String message) {
    _showSnack(context, content: Text(message));
  }

  static void _showSnack(
    BuildContext context, {
    required Widget content,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: actionLabel != null ? 6 : 4),
      ),
    );
  }

  static String _formatCopyPayload({
    required String userMessage,
    required String technicalDetail,
    LogTag? tag,
  }) {
    final build = DevContext.buildInfo;
    final lines = <String>[];
    if (build != null) {
      lines.add('${build.appName} ${build.versionLabel}');
    }
    if (tag != null) {
      lines.add('${logTagPrefix(tag)} $userMessage');
    } else {
      lines.add(userMessage);
    }
    lines.add('Technical: $technicalDetail');
    return lines.join('\n');
  }

  static Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
