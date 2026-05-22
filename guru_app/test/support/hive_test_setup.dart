import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import '../fakes/fake_repositories.dart';

final GlobalKey<ScaffoldMessengerState> guruTestScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Configures [DevContext] for widget tests that pump [GuruApp].
void configureGuruTestDevContext() {
  DevContext.resetForTest();
  DevContext.configure(
    build: const DevBuildInfo(
      appName: 'Guru Test',
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'guru.test',
    ),
    environment: DevEnvSnapshot.fromRaw({
      'APP': 'guru',
      'SYNC_BASE_URL': 'http://127.0.0.1:1',
    }),
    messengerKey: guruTestScaffoldMessengerKey,
  );
}

/// Opens Hive boxes used by [SyncService] in widget tests.
Future<void> initGuruTestHive() async {
  configureGuruTestDevContext();
  final dir = await Directory.systemTemp.createTemp('guru_hive_test');
  Hive.init(dir.path);
  Hive
    ..registerAdapter(UserAdapter())
    ..registerAdapter(MessageStatusAdapter())
    ..registerAdapter(MessageAdapter())
    ..registerAdapter(CallRequestStatusAdapter())
    ..registerAdapter(CallRequestAdapter())
    ..registerAdapter(SessionLogAdapter())
    ..registerAdapter(RoomMetaAdapter());
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.hiveBoxSettings),
    Hive.openBox<dynamic>(AppConstants.hiveBoxMessages),
    Hive.openBox(AppConstants.hiveBoxCallRequests),
    Hive.openBox(AppConstants.hiveBoxSessionLogs),
    Hive.openBox(AppConstants.hiveBoxRoomMeta),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSyncOutbox),
    Hive.openBox<dynamic>(SyncConstants.hiveBoxSyncTyping),
  ]);
}

SyncService guruTestSyncService() => SyncService(
      baseUrl: 'http://127.0.0.1:1',
      messagesBox: Hive.box<dynamic>(AppConstants.hiveBoxMessages),
      callRequestsBox: Hive.box(AppConstants.hiveBoxCallRequests),
      sessionLogsBox: Hive.box(AppConstants.hiveBoxSessionLogs),
      roomMetaBox: Hive.box(AppConstants.hiveBoxRoomMeta),
      outboxBox: Hive.box<dynamic>(AppConstants.hiveBoxSyncOutbox),
      settingsBox: Hive.box<dynamic>(AppConstants.hiveBoxSettings),
      typingBox: Hive.box<dynamic>(SyncConstants.hiveBoxSyncTyping),
      networkEnabled: false,
    );

/// Provider overrides required when a screen uses [HomeMessageSyncListener] or chat.
List<Override> guruChatSyncOverrides() => [
      sharedChatRepositoryProvider.overrideWithValue(FakeChatRepository()),
      sharedSyncServiceProvider.overrideWithValue(guruTestSyncService()),
    ];
