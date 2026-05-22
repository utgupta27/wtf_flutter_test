import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/onboarding/onboarding_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrap({bool onboardingDone = false}) => ProviderScope(
      overrides: [
        onboardingRepositoryProvider
            .overrideWithValue(FakeOnboardingRepository(done: onboardingDone)),
      ],
      child: const MaterialApp(home: OnboardingScreen()),
    );

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders slide 1 title on launch', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Welcome to WTF'), findsOneWidget);
    });

    testWidgets('shows Skip and Next buttons on first slide', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Next advances to slide 2', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Chat, Schedule & Call'), findsOneWidget);
    });

    testWidgets('page indicator shows 2 dots', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(OnboardingDot), findsNWidgets(2));
    });

    testWidgets('first dot is active on launch', (tester) async {
      await tester.pumpWidget(_wrap());
      final dots =
          tester.widgetList<OnboardingDot>(find.byType(OnboardingDot)).toList();
      expect(dots[0].active, isTrue);
      expect(dots[1].active, isFalse);
    });

    testWidgets('second dot becomes active after Next', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      final dots =
          tester.widgetList<OnboardingDot>(find.byType(OnboardingDot)).toList();
      expect(dots[0].active, isFalse);
      expect(dots[1].active, isTrue);
    });
  });
}
