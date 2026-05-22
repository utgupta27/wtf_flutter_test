import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';

/// Builds the guru app environment snapshot for the DevPanel.
DevEnvSnapshot buildGuruDevEnv() {
  return DevEnvSnapshot.fromRaw({
    'APP': 'guru',
    'ROLE': 'member',
    'USER_ID': SyncConstants.memberId,
    'DEFAULT_CHAT_ID': AppConstants.defaultChatId,
    'SYNC_BASE_URL': AppConstants.tokenServerBaseUrl,
    'HMS_TOKEN_SOURCE': 'token_server',
    'PLATFORM': _platformLabel(),
  });
}

String _platformLabel() {
  if (kIsWeb) {
    return 'web';
  }
  if (Platform.isAndroid) {
    return 'android';
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  return Platform.operatingSystem;
}
