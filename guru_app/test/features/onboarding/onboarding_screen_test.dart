import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/onboarding/onboarding_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders slide 1 title on launch', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      expect(find.text('Welcome to WTF'), findsOneWidget);
    });

    testWidgets('shows Skip and Next buttons on first slide', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Skip calls onComplete immediately', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(OnboardingScreen(onComplete: () => called = true)),
      );
      await tester.tap(find.text('Skip'));
      expect(called, isTrue);
    });

    testWidgets('Next advances to slide 2', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Chat, Schedule & Call'), findsOneWidget);
    });

    testWidgets('Get Started on slide 2 calls onComplete', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(OnboardingScreen(onComplete: () => called = true)),
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      expect(called, isTrue);
    });

    testWidgets('page indicator shows 2 dots', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      expect(find.byType(OnboardingDot), findsNWidgets(2));
    });

    testWidgets('first dot is active on launch', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      final dots = tester.widgetList<OnboardingDot>(find.byType(OnboardingDot)).toList();
      expect(dots[0].active, isTrue);
      expect(dots[1].active, isFalse);
    });

    testWidgets('second dot becomes active after Next', (tester) async {
      await tester.pumpWidget(_wrap(OnboardingScreen(onComplete: () {})));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      final dots = tester.widgetList<OnboardingDot>(find.byType(OnboardingDot)).toList();
      expect(dots[0].active, isFalse);
      expect(dots[1].active, isTrue);
    });
  });
}
