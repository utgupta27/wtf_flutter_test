import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/core/dev_env.dart';
import 'package:guru_app/core/root_scaffold.dart';
import 'package:guru_app/app.dart';
import 'package:guru_app/providers/sync_provider.dart';

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
    Hive.openBox<dynamic>(AppConstants.hiveBoxSyncOutbox),
    Hive.openBox<dynamic>(SyncConstants.hiveBoxSyncTyping),
  ]);

  final buildInfo = await DevBuildInfo.load();
  final env = buildGuruDevEnv();
  DevContext.configure(
    build: buildInfo,
    environment: env,
    messengerKey: rootScaffoldMessengerKey,
  );
  AppLog.i(LogTag.auth, 'Guru app started');

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
      child: const _SyncBootstrap(child: GuruApp()),
    ),
  );
}

/// Starts cross-app sync polling after Hive is ready.
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
