import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/home/home_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';
import '../../support/hive_test_setup.dart';

SyncService _testSync() => SyncService(
      baseUrl: 'http://127.0.0.1:1',
      messagesBox: Hive.box(AppConstants.hiveBoxMessages),
      callRequestsBox: Hive.box(AppConstants.hiveBoxCallRequests),
      sessionLogsBox: Hive.box(AppConstants.hiveBoxSessionLogs),
      roomMetaBox: Hive.box(AppConstants.hiveBoxRoomMeta),
      outboxBox: Hive.box(AppConstants.hiveBoxSyncOutbox),
      settingsBox: Hive.box(AppConstants.hiveBoxSettings),
      typingBox: Hive.box(SyncConstants.hiveBoxSyncTyping),
      networkEnabled: false,
    );

Widget _wrap() => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        sharedSyncServiceProvider.overrideWithValue(_testSync()),
        sharedChatRepositoryProvider.overrideWithValue(FakeChatRepository()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  setUpAll(() async {
    await initTrainerTestHive();
  });

  group('HomeScreen (trainer)', () {
    testWidgets('shows greeting with trainer name Aarav', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Hi, Aarav 👋'), findsOneWidget);
    });

    testWidgets('shows Trainer role badge', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Trainer'), findsOneWidget);
    });

    testWidgets('shows 4 action tiles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HomeActionTile), findsNWidgets(4));
    });

    testWidgets('shows Upcoming Calls tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Upcoming Calls'), findsOneWidget);
    });

    testWidgets('shows Chats tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Chats'), findsOneWidget);
    });

    testWidgets('shows Requests tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows Sessions tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('each tile has an icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Icon), findsAtLeast(4));
    });
  });
}
