import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/app.dart';
import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/providers/sync_provider.dart';

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
    Hive.openBox<dynamic>(AppConstants.hiveBoxSettings),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSyncOutbox),
    Hive.openBox<dynamic>(SyncConstants.hiveBoxSyncTyping),
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedChatRepositoryProvider.overrideWith(
          (ref) => HiveChatRepository(
            Hive.box<dynamic>(AppConstants.hiveBoxMessages),
          ),
        ),
        sharedSyncServiceProvider.overrideWith(
          (ref) => ref.watch(syncServiceProvider),
        ),
      ],
      child: const _SyncBootstrap(child: TrainerApp()),
    ),
  );
}

class _SyncBootstrap extends ConsumerStatefulWidget {
  const _SyncBootstrap({required this.child});
  final Widget child;

  @override
  ConsumerState<_SyncBootstrap> createState() => _SyncBootstrapState();
}

class _SyncBootstrapState extends ConsumerState<_SyncBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).startPolling();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
