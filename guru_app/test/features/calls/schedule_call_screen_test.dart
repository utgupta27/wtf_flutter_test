import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/calls/schedule_call_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrap({bool conflictResult = false}) => ProviderScope(
      overrides: [
        callRequestRepositoryProvider.overrideWithValue(
          FakeCallRequestRepository(conflictResult: conflictResult),
        ),
      ],
      child: const MaterialApp(home: ScheduleCallScreen()),
    );

void main() {
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

    testWidgets('shows error when submitting without a time slot', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pump();
      expect(find.text('Please select a time slot'), findsOneWidget);
    });

    testWidgets('shows success view after valid submission', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Select the first time slot chip (after the 3 day chips)
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      // First 3 are day chips; pick chip index 3 (first time slot)
      final slotChip = find.byWidget(chips[3]);
      await tester.tap(slotChip);
      await tester.pump();

      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Request Sent!'), findsOneWidget);
    });

    testWidgets('shows conflict error when slot is already booked', (tester) async {
      await tester.pumpWidget(_wrap(conflictResult: true));
      await tester.pump();

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      final slotChip = find.byWidget(chips[3]);
      await tester.tap(slotChip);
      await tester.pump();

      await tester.ensureVisible(find.text('Request Call'));
      await tester.pump();
      await tester.tap(find.text('Request Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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
