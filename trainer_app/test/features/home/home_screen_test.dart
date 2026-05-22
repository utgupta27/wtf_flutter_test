import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trainer_app/features/home/home_screen.dart';
import 'package:trainer_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrap() => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  group('HomeScreen (trainer)', () {
    testWidgets('shows greeting with trainer name Aarav', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Hi, Aarav 👋'), findsOneWidget);
    });

    testWidgets('shows Trainer role badge', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Trainer'), findsOneWidget);
    });

    testWidgets('shows 4 action tiles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(HomeActionTile), findsNWidgets(4));
    });

    testWidgets('shows Members tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Members'), findsOneWidget);
    });

    testWidgets('shows Chats tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Chats'), findsOneWidget);
    });

    testWidgets('shows Requests tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows Sessions tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('each tile has an icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Icon), findsAtLeast(4));
    });
  });
}
