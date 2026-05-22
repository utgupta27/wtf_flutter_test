import 'package:flutter/material.dart';

import 'package:shared/observability/app_error_surface.dart';
import 'package:shared/observability/dev_build_info.dart';
import 'package:shared/observability/dev_env_snapshot.dart';
import 'package:shared/observability/log_tag.dart';

/// Session-scoped dev panel inputs set from each app's [main].
class DevContext {
  DevContext._();

  static DevBuildInfo? buildInfo;
  static DevEnvSnapshot? env;
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  static void configure({
    required DevBuildInfo build,
    required DevEnvSnapshot environment,
    required GlobalKey<ScaffoldMessengerState> messengerKey,
  }) {
    buildInfo = build;
    env = environment;
    scaffoldMessengerKey = messengerKey;
  }

  /// Surfaces an operational error when a root messenger is configured.
  static void surfaceError({
    required String userMessage,
    required String technicalDetail,
    LogTag? tag,
  }) {
    final messenger = scaffoldMessengerKey?.currentState;
    if (messenger == null) {
      return;
    }
    AppErrorSurface.showErrorWithMessenger(
      messenger,
      userMessage: userMessage,
      technicalDetail: technicalDetail,
      tag: tag,
    );
  }

  static void resetForTest() {
    buildInfo = null;
    env = null;
    scaffoldMessengerKey = null;
    DevBuildInfo.resetForTest();
  }
}
