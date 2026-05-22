import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared/shared.dart';

import 'package:trainer_app/core/constants.dart';

/// Builds the trainer app environment snapshot for the DevPanel.
DevEnvSnapshot buildTrainerDevEnv() {
  return DevEnvSnapshot.fromRaw({
    'APP': 'trainer',
    'ROLE': 'trainer',
    'USER_ID': SyncConstants.trainerId,
    'DEFAULT_CHAT_ID': SyncConstants.defaultChatId,
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
