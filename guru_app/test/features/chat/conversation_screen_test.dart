import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/chat/conversation_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

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

Widget _wrap({List<Message> messages = const []}) => ProviderScope(
      overrides: [
        chatRepositoryProvider.overrideWithValue(
          FakeChatRepository(messages: List.from(messages)),
        ),
      ],
      child: const MaterialApp(
        home: ConversationScreen(chatId: _chatId),
      ),
    );

void main() {
  group('ConversationScreen', () {
    testWidgets('renders AppBar with trainer name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Aarav'), findsOneWidget);
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
