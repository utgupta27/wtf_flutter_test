import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/sessions/session_logs_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

SessionLog _log(String id, {String? trainerNotes}) => SessionLog(
      id: id,
      memberId: 'member-dk-001',
      trainerId: 'trainer-aarav-001',
      startedAt: DateTime(2026, 1, 1, 10),
      endedAt: DateTime(2026, 1, 1, 11),
      durationSec: 3600,
      trainerNotes: trainerNotes,
    );

Widget _wrap({List<SessionLog> logs = const []}) => ProviderScope(
      overrides: [
        sessionLogRepositoryProvider.overrideWithValue(
          FakeSessionLogRepository(logs: List.from(logs)),
        ),
        callRequestRepositoryProvider.overrideWithValue(
          FakeCallRequestRepository(),
        ),
      ],
      child: const MaterialApp(home: SessionLogsScreen()),
    );

void main() {
  group('SessionLogsScreen (trainer)', () {
    testWidgets('shows Sessions AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('shows empty state when no sessions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No sessions yet'), findsOneWidget);
    });

    testWidgets('shows session tile when logs exist', (tester) async {
      await tester.pumpWidget(_wrap(logs: [_log('1')]));
      await tester.pump();
      expect(find.byType(SessionLogTile), findsOneWidget);
    });

    testWidgets('tile shows session with DK', (tester) async {
      await tester.pumpWidget(_wrap(logs: [_log('1')]));
      await tester.pump();
      expect(find.text('Session with DK'), findsOneWidget);
    });

    testWidgets('shows Add note button when no notes', (tester) async {
      await tester.pumpWidget(_wrap(logs: [_log('1')]));
      await tester.pump();
      expect(find.text('Add note'), findsOneWidget);
    });

    testWidgets('shows Edit note button when note exists', (tester) async {
      await tester.pumpWidget(
          _wrap(logs: [_log('1', trainerNotes: 'Great session!')]));
      await tester.pump();
      expect(find.text('Edit note'), findsOneWidget);
    });

    testWidgets('shows existing trainer note text', (tester) async {
      await tester.pumpWidget(
          _wrap(logs: [_log('1', trainerNotes: 'Great session!')]));
      await tester.pump();
      expect(find.text('Great session!'), findsOneWidget);
    });
  });
}
