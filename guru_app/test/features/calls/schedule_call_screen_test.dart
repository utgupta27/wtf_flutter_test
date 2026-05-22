import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/calls/schedule_call_screen.dart';
import 'package:guru_app/core/constants.dart';
import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';
import '../../fakes/fake_repositories.dart';
import '../../support/hive_test_setup.dart';

Widget _wrap({bool conflictResult = false}) => ProviderScope(
      overrides: [
        chatRepositoryProvider.overrideWithValue(FakeChatRepository()),
        callRequestRepositoryProvider.overrideWithValue(
          FakeCallRequestRepository(conflictResult: conflictResult),
        ),
        syncServiceProvider.overrideWithValue(
          SyncService(
            baseUrl: AppConstants.tokenServerBaseUrl,
            messagesBox: Hive.box<dynamic>(AppConstants.hiveBoxMessages),
            callRequestsBox: Hive.box(AppConstants.hiveBoxCallRequests),
            sessionLogsBox: Hive.box(AppConstants.hiveBoxSessionLogs),
            roomMetaBox: Hive.box(AppConstants.hiveBoxRoomMeta),
            outboxBox: Hive.box<dynamic>(AppConstants.hiveBoxSyncOutbox),
            settingsBox: Hive.box<dynamic>(AppConstants.hiveBoxSettings),
            typingBox: Hive.box<dynamic>(SyncConstants.hiveBoxSyncTyping),
            networkEnabled: false,
          ),
        ),
      ],
      child: const MaterialApp(home: ScheduleCallScreen()),
    );

void main() {
  setUpAll(() async {
    await initGuruTestHive();
  });

  group('ScheduleCallScreen', () {
    testWidgets('renders AppBar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Schedule a Call'), findsOneWidget);
    });

    testWidgets('shows 3 day selector chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ChoiceChip), findsAtLeast(3));
    });

    testWidgets('note text field is present', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('submit button is present', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Request Call'), findsOneWidget);
    });

    testWidgets('schedule in 1 minute button submits request', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.ensureVisible(find.text('Schedule in 1 minute'));
      await tester.pump();
      await tester.tap(find.text('Schedule in 1 minute'));
      await tester.pumpAndSettle();

      expect(find.text(UiCopy.callRequestedWaiting), findsWidgets);
    });

    testWidgets('shows error when submitting without a time slot', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pump();
      expect(find.text('Please select a time slot'), findsOneWidget);
    });

    Future<void> pickFutureSlot(WidgetTester tester) async {
      final dayChips =
          tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      await tester.tap(find.byWidget(dayChips[2]));
      await tester.pump();
      final allChips =
          tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      await tester.tap(find.byWidget(allChips.last));
      await tester.pump();
    }

    testWidgets('shows success view after valid submission', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await pickFutureSlot(tester);

      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pumpAndSettle();

      expect(find.text(UiCopy.callRequestedWaiting), findsWidgets);
    });

    testWidgets('shows conflict error when slot is already booked', (tester) async {
      await tester.pumpWidget(_wrap(conflictResult: true));
      await tester.pump();

      await pickFutureSlot(tester);

      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pumpAndSettle();

      expect(find.textContaining('already booked'), findsOneWidget);
    });

    testWidgets('note field accepts text up to 140 chars', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Focus on upper body');
      await tester.pump();
      expect(find.text('Focus on upper body'), findsOneWidget);
    });
  });
}
