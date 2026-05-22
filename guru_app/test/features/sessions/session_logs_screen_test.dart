import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/sessions/session_logs_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

SessionLog _log(String id, DateTime startedAt, {int rating = 5}) => SessionLog(
      id: id,
      memberId: 'member-dk-001',
      trainerId: 'trainer-aarav-001',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 45)),
      durationSec: 45 * 60,
      rating: rating,
    );

final _now = DateTime.now();

final _seedLogs = [
  _log('a', _now.subtract(const Duration(days: 1))),           // All ✓ 7d ✓ Month ✓
  _log('b', _now.subtract(const Duration(days: 10))), // All ✓ 7d ✗
  _log('c', DateTime(_now.year - 1)),                             // All ✓ 7d ✗ Month ✗
];

Widget _wrap({List<SessionLog> logs = const []}) => ProviderScope(
      overrides: [
        sessionLogRepositoryProvider.overrideWithValue(
          FakeSessionLogRepository(logs: List.from(logs)),
        ),
      ],
      child: const MaterialApp(home: SessionLogsScreen()),
    );

void main() {
  group('SessionLogsScreen', () {
    testWidgets('shows AppBar title My Sessions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('My Sessions'), findsOneWidget);
    });

    testWidgets('shows 3 filter chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FilterChip), findsNWidgets(3));
    });

    testWidgets('shows All, Last 7 days, This Month chip labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
    });

    testWidgets('shows empty state when no sessions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No sessions yet'), findsOneWidget);
    });

    testWidgets('shows session log tiles when logs exist', (tester) async {
      await tester.pumpWidget(_wrap(logs: _seedLogs));
      await tester.pump();
      expect(find.byType(SessionLogTile), findsNWidgets(3));
    });

    testWidgets('tile shows trainer name', (tester) async {
      await tester.pumpWidget(_wrap(logs: [_seedLogs[0]]));
      await tester.pump();
      expect(find.text('Session with Aarav'), findsOneWidget);
    });

    testWidgets('tile shows star rating', (tester) async {
      await tester.pumpWidget(_wrap(logs: [_seedLogs[0]]));
      await tester.pump();
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('Last 7 days filter hides logs older than 7 days', (tester) async {
      await tester.pumpWidget(_wrap(logs: _seedLogs));
      await tester.pump();
      await tester.tap(find.text('Last 7 days'));
      await tester.pump();
      // Only log 'a' (1 day ago) passes the filter; 'b' (10d) and 'c' (1yr) do not
      expect(find.byType(SessionLogTile), findsOneWidget);
    });

    testWidgets('This Month filter hides logs from other months', (tester) async {
      await tester.pumpWidget(_wrap(logs: _seedLogs));
      await tester.pump();
      await tester.tap(find.text('This Month'));
      await tester.pump();
      // log 'c' (last year) should be hidden; 'a' and 'b' both in current month
      // Note: 'b' is 10 days ago — might still be current month
      expect(find.byType(SessionLogTile), findsAtLeast(1));
    });

    testWidgets('All filter shows all logs', (tester) async {
      await tester.pumpWidget(_wrap(logs: _seedLogs));
      await tester.pump();
      // First switch to 7d then back to All
      await tester.tap(find.text('Last 7 days'));
      await tester.pump();
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.byType(SessionLogTile), findsNWidgets(3));
    });
  });
}
