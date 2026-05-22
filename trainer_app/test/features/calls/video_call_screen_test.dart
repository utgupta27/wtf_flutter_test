import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trainer_app/features/calls/video_call_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

const _requestId = 'request-001';

Widget _wrap({bool joinError = false}) => ProviderScope(
      overrides: [
        videoCallServiceProvider.overrideWithValue(
          FakeVideoCallService(joinError: joinError ? 'Network error' : null),
        ),
        sessionLogRepositoryProvider.overrideWithValue(
          FakeSessionLogRepository(),
        ),
      ],
      child: const MaterialApp(home: VideoCallScreen(requestId: _requestId)),
    );

void main() {
  group('VideoCallScreen (trainer) — pre-join', () {
    testWidgets('shows Ready to Join AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Ready to Join?'), findsOneWidget);
    });

    testWidgets('shows member name DK', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('DK'), findsAtLeast(1));
    });

    testWidgets('shows Join Call button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Join Call'), findsOneWidget);
    });
  });

  group('VideoCallScreen (trainer) — in-call', () {
    Future<void> joinCall(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('transitions to in-call after Join Call', (tester) async {
      await joinCall(tester);
      expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);
    });

    testWidgets('shows timer', (tester) async {
      await joinCall(tester);
      expect(find.text('00:00'), findsOneWidget);
    });
  });

  group('VideoCallScreen (trainer) — notes phase', () {
    Future<void> reachNotes(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.call_end_rounded));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows Session Notes screen', (tester) async {
      await reachNotes(tester);
      expect(find.text('Session Notes'), findsOneWidget);
    });

    testWidgets('shows notes TextField', (tester) async {
      await reachNotes(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows Save & Finish button', (tester) async {
      await reachNotes(tester);
      expect(find.text('Save & Finish'), findsOneWidget);
    });

    testWidgets('saving shows done view', (tester) async {
      await reachNotes(tester);
      await tester.tap(find.text('Save & Finish'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Session Logged!'), findsOneWidget);
    });
  });

  group('VideoCallScreen (trainer) — error', () {
    testWidgets('shows error when join fails', (tester) async {
      await tester.pumpWidget(_wrap(joinError: true));
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Network error'), findsOneWidget);
    });
  });
}
