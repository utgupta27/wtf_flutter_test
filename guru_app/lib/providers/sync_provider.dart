import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    baseUrl: AppConstants.tokenServerBaseUrl,
    messagesBox: Hive.box<dynamic>(AppConstants.hiveBoxMessages),
    callRequestsBox: Hive.box(AppConstants.hiveBoxCallRequests),
    sessionLogsBox: Hive.box(AppConstants.hiveBoxSessionLogs),
    roomMetaBox: Hive.box(AppConstants.hiveBoxRoomMeta),
    outboxBox: Hive.box<dynamic>(AppConstants.hiveBoxSyncOutbox),
    settingsBox: Hive.box<dynamic>(AppConstants.hiveBoxSettings),
    typingBox: Hive.box<dynamic>(SyncConstants.hiveBoxSyncTyping),
  );
  ref.onDispose(service.dispose);
  return service;
});

final syncTickProvider = StreamProvider<void>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.ticks;
});
