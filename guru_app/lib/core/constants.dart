import 'package:shared/constants/sync_constants.dart';

abstract class AppConstants {
  static String get tokenServerBaseUrl => SyncConstants.syncBaseUrl;
  static const hiveBoxUsers = 'users';
  static const hiveBoxMessages = 'messages';
  static const hiveBoxCallRequests = 'call_requests';
  static const hiveBoxSessionLogs = 'session_logs';
  static const hiveBoxRoomMeta = 'room_meta';
  static const hiveBoxSettings = 'settings';
  static const hiveBoxSyncOutbox = 'sync_outbox';
  static const settingsKeyOnboardingDone = 'onboarding_done';
  static const defaultChatId = 'chat-dk-aarav';
}
