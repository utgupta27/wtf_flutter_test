import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MessageStatusAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(CallRequestStatusAdapter());
  Hive.registerAdapter(CallRequestAdapter());
  Hive.registerAdapter(SessionLogAdapter());
  Hive.registerAdapter(RoomMetaAdapter());

  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.hiveBoxSettings),
    Hive.openBox<dynamic>(AppConstants.hiveBoxUsers),
    Hive.openBox<dynamic>(AppConstants.hiveBoxMessages),
    Hive.openBox<dynamic>(AppConstants.hiveBoxCallRequests),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSessionLogs),
    Hive.openBox<dynamic>(AppConstants.hiveBoxRoomMeta),
  ]);

  runApp(const ProviderScope(child: GuruApp()));
}
