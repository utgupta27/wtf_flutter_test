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

  await Hive.openBox(AppConstants.hiveBoxSettings);

  runApp(const ProviderScope(child: GuruApp()));
}
