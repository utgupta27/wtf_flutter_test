import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/chat/chat_list_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

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

Widget _wrap({List<Message> messages = const []}) => ProviderScope(
      overrides: [
        chatRepositoryProvider.overrideWithValue(
          FakeChatRepository(messages: List.from(messages)),
        ),
      ],
      child: const MaterialApp(home: ChatListScreen()),
    );

void main() {
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
      // 'DK' appears in both the CircleAvatar label and the tile title
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
      expect(find.byType(UnreadBadge), findsOneWidget);
    });

    testWidgets('no unread badge when message is read', (tester) async {
      await tester.pumpWidget(_wrap(messages: [
        _msg('1', 'Hey!', status: MessageStatus.read),
      ]));
      await tester.pump();
      expect(find.byType(UnreadBadge), findsNothing);
    });
  });
}
