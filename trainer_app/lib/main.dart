import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/app.dart';
import 'package:trainer_app/core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

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
  ]);

  runApp(const ProviderScope(child: TrainerApp()));
}
