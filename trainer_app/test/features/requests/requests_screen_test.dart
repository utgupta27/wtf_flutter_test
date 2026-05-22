import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/requests/requests_screen.dart';
import '../../support/hive_test_setup.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

CallRequest _req(String id, {CallRequestStatus status = CallRequestStatus.pending}) =>
    CallRequest(
      id: id,
      memberId: 'member-dk-001',
      trainerId: 'trainer-aarav-001',
      requestedAt: DateTime(2026, 1, 1, 9),
      scheduledFor: DateTime(2026, 1, 2, 10),
      note: 'Focus on upper body',
      status: status,
    );

Widget _wrap({List<CallRequest> requests = const []}) => ProviderScope(
      overrides: [
        callRequestRepositoryProvider.overrideWithValue(
          FakeCallRequestRepository(requests: List.from(requests)),
        ),
        chatRepositoryProvider.overrideWithValue(
          FakeChatRepository(),
        ),
      ],
      child: const MaterialApp(home: RequestsScreen()),
    );

void main() {
  setUpAll(() async {
    await initTrainerTestHive();
  });

  group('RequestsScreen', () {
    testWidgets('shows AppBar title Requests', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows empty state when no requests', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No requests'), findsOneWidget);
    });

    testWidgets('shows request card for pending request', (tester) async {
      await tester.pumpWidget(_wrap(requests: [_req('1')]));
      await tester.pump();
      expect(find.byType(RequestCard), findsOneWidget);
    });

    testWidgets('shows Approve and Decline buttons', (tester) async {
      await tester.pumpWidget(_wrap(requests: [_req('1')]));
      await tester.pump();
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('shows note text on the card', (tester) async {
      await tester.pumpWidget(_wrap(requests: [_req('1')]));
      await tester.pump();
      expect(find.text('Focus on upper body'), findsOneWidget);
    });

    testWidgets('shows approved requests in approved section', (tester) async {
      await tester.pumpWidget(_wrap(requests: [
        _req('1', status: CallRequestStatus.approved),
      ]));
      await tester.pump();
      expect(find.text('Approved'), findsWidgets);
      expect(find.byType(ApprovedRequestCard), findsOneWidget);
    });

    testWidgets('tapping Approve removes card from list', (tester) async {
      await tester.pumpWidget(_wrap(requests: [_req('1')]));
      await tester.pump();
      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(RequestCard), findsNothing);
    });

    testWidgets('tapping Decline removes card from list', (tester) async {
      await tester.pumpWidget(_wrap(requests: [_req('1')]));
      await tester.pump();
      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Schedule conflict');
      await tester.tap(find.text('Decline').last);
      await tester.pumpAndSettle();
      expect(find.byType(RequestCard), findsNothing);
    });
  });
}
