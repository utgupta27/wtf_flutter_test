import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/chat/chat_list_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

const _chatId = 'chat-dk-aarav';

Message _msg(String id, String text, {MessageStatus status = MessageStatus.sent}) =>
    Message(
      id: id,
      chatId: _chatId,
      senderId: 'trainer-aarav-001',
      receiverId: 'member-dk-001',
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
  group('ChatListScreen', () {
    testWidgets('shows empty state when no messages', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('shows conversation tile when messages exist', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'See you at 6!')]));
      await tester.pump();
      expect(find.byType(ChatListTile), findsOneWidget);
    });

    testWidgets('shows trainer name in tile', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'See you at 6!')]));
      await tester.pump();
      expect(find.text('Aarav'), findsOneWidget);
    });

    testWidgets('shows last message preview', (tester) async {
      await tester.pumpWidget(_wrap(messages: [_msg('1', 'See you at 6!')]));
      await tester.pump();
      expect(find.text('See you at 6!'), findsOneWidget);
    });

    testWidgets('shows unread badge when trainer message is unread', (tester) async {
      await tester.pumpWidget(_wrap(messages: [
        _msg('1', 'Hey!'),
      ]));
      await tester.pump();
      expect(find.byType(UnreadBadge), findsOneWidget);
    });

    testWidgets('no unread badge when all trainer messages are read', (tester) async {
      await tester.pumpWidget(_wrap(messages: [
        _msg('1', 'Hey!', status: MessageStatus.read),
      ]));
      await tester.pump();
      expect(find.byType(UnreadBadge), findsNothing);
    });
  });
}
