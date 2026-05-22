import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/chat/conversation_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

final _sampleMessages = [
  Message(
    id: '1',
    chatId: 'chat-1',
    senderId: 'member-dk-001',
    receiverId: 'trainer-aarav-001',
    text: 'Hey Aarav!',
    createdAt: DateTime(2026, 1, 1, 10),
    status: MessageStatus.read,
  ),
  Message(
    id: '2',
    chatId: 'chat-1',
    senderId: 'trainer-aarav-001',
    receiverId: 'member-dk-001',
    text: 'Hi DK, ready to train?',
    createdAt: DateTime(2026, 1, 1, 10, 1),
    status: MessageStatus.sent,
  ),
];

void main() {
  group('ConversationScreen', () {
    testWidgets('renders AppBar with trainer name', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: _sampleMessages,
        onSend: (_) {},
      )));
      expect(find.text('Aarav'), findsOneWidget);
    });

    testWidgets('renders member bubble on right', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: _sampleMessages,
        onSend: (_) {},
      )));
      expect(find.text('Hey Aarav!'), findsOneWidget);
    });

    testWidgets('renders trainer bubble on left', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: _sampleMessages,
        onSend: (_) {},
      )));
      expect(find.text('Hi DK, ready to train?'), findsOneWidget);
    });

    testWidgets('shows text input field', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: const [],
        onSend: (_) {},
      )));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button calls onSend with text', (tester) async {
      String? sent;
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: const [],
        onSend: (text) => sent = text,
      )));
      await tester.enterText(find.byType(TextField), 'Hello!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      expect(sent, 'Hello!');
    });

    testWidgets('send button clears input after send', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: const [],
        onSend: (_) {},
      )));
      await tester.enterText(find.byType(TextField), 'Hello!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(find.text('Hello!'), findsNothing);
    });

    testWidgets('read message shows double tick', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: _sampleMessages,
        onSend: (_) {},
      )));
      expect(find.byIcon(Icons.done_all_rounded), findsWidgets);
    });

    testWidgets('shows typing indicator when isTyping is true', (tester) async {
      await tester.pumpWidget(_wrap(ConversationScreen(
        currentUserId: 'member-dk-001',
        otherUserName: 'Aarav',
        messages: const [],
        onSend: (_) {},
        isTyping: true,
      )));
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}
