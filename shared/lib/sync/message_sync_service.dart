import 'dart:async';

import 'package:shared/constants/sync_constants.dart';
import 'package:shared/sync/sync_service.dart';

/// Focused API for cross-app chat message replication.
class MessageSyncService {
  MessageSyncService(this._sync);

  final SyncService _sync;

  /// Fires after a successful message pull/push cycle.
  Stream<void> get ticks => _sync.ticks;

  /// Push pending messages and pull all remote updates for the default chat.
  Future<void> syncNow() => _sync.syncMessagesNow();

  /// Start background polling (delegates to full [SyncService]).
  void startPolling({Duration interval = const Duration(milliseconds: 1500)}) {
    _sync.startPolling(interval: interval);
  }

  void stopPolling() => _sync.stopPolling();

  /// Chat id used for cross-app demo thread.
  static String get defaultChatId => SyncConstants.defaultChatId;
}
