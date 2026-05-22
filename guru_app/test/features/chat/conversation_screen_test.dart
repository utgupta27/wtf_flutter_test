import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/chat/conversation_screen.dart';
import '../../fakes/fake_repositories.dart';
import '../../support/hive_test_setup.dart';

const _chatId = 'chat-dk-aarav';

final _seedMessages = [
  Message(
    id: '1',
    chatId: _chatId,
    senderId: 'member-dk-001',
    receiverId: 'trainer-aarav-001',
    text: 'Hey Aarav!',
    createdAt: DateTime(2026, 1, 1, 10),
    status: MessageStatus.read, // member msg → shows done_all
  ),
  Message(
    id: '2',
    chatId: _chatId,
    senderId: 'member-dk-001',
    receiverId: 'trainer-aarav-001',
    text: 'On my way!',
    createdAt: DateTime(2026, 1, 1, 10, 1),
    status: MessageStatus.sent, // member msg → shows done
  ),
  Message(
    id: '3',
    chatId: _chatId,
    senderId: 'trainer-aarav-001',
    receiverId: 'member-dk-001',
    text: 'Hi DK, ready to train?',
    createdAt: DateTime(2026, 1, 1, 10, 2),
    status: MessageStatus.read,
  ),
];

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

Widget _wrap({List<Message> messages = const []}) => ProviderScope(
      overrides: [
        sharedChatRepositoryProvider.overrideWithValue(
          FakeChatRepository(messages: List.from(messages)),
        ),
        sharedSyncServiceProvider.overrideWithValue(_testSync()),
      ],
      child: const MaterialApp(
        home: ConversationScreen(chatId: _chatId),
      ),
    );

void main() {
  setUpAll(() async {
    await initGuruTestHive();
  });

  group('ConversationScreen', () {
    testWidgets('renders AppBar with trainer name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Aarav'), findsOneWidget);
    });

    testWidgets('shows empty chat copy when no messages', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text(UiCopy.emptyChat), findsOneWidget);
    });

    testWidgets('renders member bubble text', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.text('Hey Aarav!'), findsOneWidget);
    });

    testWidgets('renders trainer bubble text', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.text('Hi DK, ready to train?'), findsOneWidget);
    });

    testWidgets('shows text input field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button is present', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('shows quick reply chips', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.text('Got it 👍'), findsOneWidget);
    });

    testWidgets('shows attach image button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('read message shows double tick icon', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    testWidgets('sent message shows single tick icon', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.byIcon(Icons.done_rounded), findsOneWidget);
    });
  });
}
