import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/chat/chat_list_screen.dart';
import '../../fakes/fake_repositories.dart';
import '../../support/hive_test_setup.dart';

const _chatId = 'chat-dk-aarav';

Message _msg(String id, String text, {MessageStatus status = MessageStatus.sent}) =>
    Message(
      id: id,
      chatId: _chatId,
      senderId: 'member-dk-001',
      receiverId: 'trainer-aarav-001',
      text: text,
      createdAt: DateTime.now(),
      status: status,
    );

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
      child: const MaterialApp(home: ChatListScreen()),
    );

void main() {
  setUpAll(() async {
    await initTrainerTestHive();
  });

  group('ChatListScreen (trainer)', () {
    testWidgets('shows empty state when no messages', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('shows chat tile when messages exist', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'Ready!')]));
      await tester.pump();
      expect(find.byType(ChatListTile), findsOneWidget);
    });

    testWidgets('tile shows member name DK', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'Ready!')]));
      await tester.pump();
      expect(find.text('DK'), findsAtLeast(1));
    });

    testWidgets('tile shows last message preview', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'Ready!')]));
      await tester.pump();
      expect(find.text('Ready!'), findsOneWidget);
    });

    testWidgets('shows unread badge for unread member messages', (tester) async {
      await tester.pumpWidget(_wrap(messages: [
        _msg('1', 'Hey!', status: MessageStatus.sending),
      ]));
      await tester.pump();
      expect(find.byType(ChatUnreadBadge), findsOneWidget);
    });

    testWidgets('no unread badge when message is read', (tester) async {
      await tester.pumpWidget(_wrap(messages: [
        _msg('1', 'Hey!', status: MessageStatus.read),
      ]));
      await tester.pump();
      expect(find.byType(ChatUnreadBadge), findsNothing);
    });
  });
}
