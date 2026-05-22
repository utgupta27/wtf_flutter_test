import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/call_permissions.dart';
import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/calls/video_call_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';
import '../../support/hive_test_setup.dart';

const _requestId = 'request-001';

Widget _wrap({bool joinError = false}) => ProviderScope(
      overrides: [
        videoCallServiceProvider.overrideWithValue(
          FakeVideoCallService(joinError: joinError ? 'Network error' : null),
        ),
        sessionLogRepositoryProvider.overrideWithValue(
          FakeSessionLogRepository(),
        ),
        callRequestRepositoryProvider.overrideWithValue(
          FakeCallRequestRepository(
            requests: [
              CallRequest(
                id: _requestId,
                memberId: SyncConstants.memberId,
                trainerId: SyncConstants.trainerId,
                requestedAt: DateTime.now(),
                scheduledFor: DateTime.now().add(const Duration(seconds: 30)),
                note: 'Test',
                status: CallRequestStatus.approved,
              ),
            ],
          ),
        ),
      ],
      child: const MaterialApp(
        home: VideoCallScreen(requestId: _requestId),
      ),
    );

void main() {
  setUpAll(() async {
    await initGuruTestHive();
  });

  setUp(() async {
    callPermissionCheckerOverride = () async => true;
    final box = Hive.box(AppConstants.hiveBoxRoomMeta);
    await box.put(
      _requestId,
      const RoomMeta(
        id: 'meta-1',
        callRequestId: _requestId,
        hmsRoomId: 'room-test',
        hmsRoleMember: 'member',
        hmsRoleTrainer: 'trainer',
      ),
    );
  });

  tearDown(() {
    callPermissionCheckerOverride = null;
  });

  group('VideoCallScreen — pre-join', () {
    testWidgets('shows join prompt on pre-join', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text(UiCopy.joinPrompt), findsOneWidget);
    });

    testWidgets('shows trainer name Aarav', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Aarav'), findsOneWidget);
    });

    testWidgets('shows Join Call button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Join Call'), findsOneWidget);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('VideoCallScreen — in-call phase', () {
    Future<void> joinCall(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump(); // join() fires
      await tester.pump(); // stream event processed
    }

    testWidgets('transitions to in-call after Join Call', (tester) async {
      await joinCall(tester);
      expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);
    });

    testWidgets('shows mic toggle button', (tester) async {
      await joinCall(tester);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    testWidgets('shows camera toggle button', (tester) async {
      await joinCall(tester);
      expect(find.byIcon(Icons.videocam_rounded), findsOneWidget);
    });

    testWidgets('shows timer display', (tester) async {
      await joinCall(tester);
      expect(find.text('00:00'), findsOneWidget);
    });
  });

  group('VideoCallScreen — rating phase', () {
    Future<void> reachRating(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump();
      await tester.pump();
      // End the call
      await tester.tap(find.byIcon(Icons.call_end_rounded));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows How was your session?', (tester) async {
      await reachRating(tester);
      expect(find.text('How was your session?'), findsOneWidget);
    });

    testWidgets('shows 5 star icons', (tester) async {
      await reachRating(tester);
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));
    });

    testWidgets('shows Submit Rating button', (tester) async {
      await reachRating(tester);
      expect(find.text('Submit Rating'), findsOneWidget);
    });

    testWidgets('error shown when submitting without rating', (tester) async {
      await reachRating(tester);
      await tester.tap(find.text('Submit Rating'));
      await tester.pump();
      expect(find.text('Please select a rating'), findsOneWidget);
    });

    testWidgets('submitting with rating shows done view', (tester) async {
      await reachRating(tester);
      // Tap 4th star
      final stars = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .toList();
      await tester.tap(find.byWidget(stars[3]));
      await tester.pump();
      await tester.tap(find.text('Submit Rating'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Session Logged!'), findsOneWidget);
    });
  });

  group('VideoCallScreen — error handling', () {
    testWidgets('shows error message when join fails', (tester) async {
      await tester.pumpWidget(_wrap(joinError: true));
      await tester.pump();
      await tester.tap(find.text('Join Call'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('Network error'), findsOneWidget);
    });
  });
}
