import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/core/constants.dart';

Future<void> initTrainerTestHive() async {
  final dir = await Directory.systemTemp.createTemp('trainer_hive_test');
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
    Hive.openBox(AppConstants.hiveBoxUsers),
    Hive.openBox(AppConstants.hiveBoxMessages),
    Hive.openBox(AppConstants.hiveBoxCallRequests),
    Hive.openBox(AppConstants.hiveBoxSessionLogs),
    Hive.openBox(AppConstants.hiveBoxRoomMeta),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSettings),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSyncOutbox),
    Hive.openBox<dynamic>(SyncConstants.hiveBoxSyncTyping),
  ]);
}
