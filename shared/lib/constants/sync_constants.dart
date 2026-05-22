import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Shared IDs and sync tuning for cross-app demo.
abstract class SyncConstants {
  /// Node sync hub URL (Android emulator → host via 10.0.2.2).
  static String get syncBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }
  static const defaultChatId = 'chat-dk-aarav';
  static const memberId = 'member-dk-001';
  static const trainerId = 'trainer-aarav-001';

  /// Join opens this many minutes before scheduledFor (spec: 10).
  static const joinWindowMinutes = 10;

  static const hiveBoxSyncTyping = 'sync_typing';
}
