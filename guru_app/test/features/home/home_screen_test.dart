import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/home/home_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrapWithScope() => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

void main() {
  group('HomeScreen', () {
    testWidgets('shows 3 action cards', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.byType(HomeActionCard), findsNWidgets(3));
    });

    testWidgets('shows Chat with Trainer card', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.text('Chat with Trainer'), findsOneWidget);
    });

    testWidgets('shows Schedule Call card', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.text('Schedule Call'), findsOneWidget);
    });

    testWidgets('shows My Sessions card', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.text('My Sessions'), findsOneWidget);
    });

    testWidgets('AppBar shows Member role badge', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('AppBar shows greeting with user name from ViewModel',
        (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump(); // settle async auth load
      expect(find.text('Hi, DK 👋'), findsOneWidget);
    });

    testWidgets('each card has an icon', (tester) async {
      await tester.pumpWidget(_wrapWithScope());
      await tester.pump();
      expect(find.byType(Icon), findsAtLeast(3));
    });
  });
}
