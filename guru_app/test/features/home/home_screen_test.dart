import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/home/home_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('HomeScreen', () {
    testWidgets('shows 3 action cards', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.byType(HomeActionCard), findsNWidgets(3));
    });

    testWidgets('shows Chat with Trainer card', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.text('Chat with Trainer'), findsOneWidget);
    });

    testWidgets('shows Schedule Call card', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.text('Schedule Call'), findsOneWidget);
    });

    testWidgets('shows My Sessions card', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.text('My Sessions'), findsOneWidget);
    });

    testWidgets('AppBar shows Member role badge', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('AppBar shows greeting', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.text('Hi, DK 👋'), findsOneWidget);
    });

    testWidgets('each card has an icon', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      expect(find.byType(Icon), findsAtLeast(3));
    });
  });
}
