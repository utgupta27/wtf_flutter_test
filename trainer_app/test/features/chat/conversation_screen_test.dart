import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/chat/conversation_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

const _chatId = 'chat-dk-aarav';

final _seedMessages = [
  Message(
    id: '1',
    chatId: _chatId,
    senderId: 'member-dk-001',
    receiverId: 'trainer-aarav-001',
    text: 'Ready to train!',
    createdAt: DateTime(2026, 1, 1, 10),
    status: MessageStatus.read,
  ),
  Message(
    id: '2',
    chatId: _chatId,
    senderId: 'trainer-aarav-001',
    receiverId: 'member-dk-001',
    text: 'Great, see you at 6!',
    createdAt: DateTime(2026, 1, 1, 10, 1),
    status: MessageStatus.sent,
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
  group('ConversationScreen (trainer)', () {
    testWidgets('shows AppBar with member name DK', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('DK'), findsOneWidget);
    });

    testWidgets('shows member bubble text', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.text('Ready to train!'), findsOneWidget);
    });

    testWidgets('shows trainer bubble text', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.text('Great, see you at 6!'), findsOneWidget);
    });

    testWidgets('shows text input field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows send button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('sent trainer message shows single tick', (tester) async {
      await tester.pumpWidget(_wrap(messages: _seedMessages));
      await tester.pump();
      expect(find.byIcon(Icons.done_rounded), findsOneWidget);
    });
  });
}
