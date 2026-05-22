import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/features/onboarding/onboarding_screen.dart';
import 'package:guru_app/providers/repository_providers.dart';
import '../../fakes/fake_repositories.dart';

Widget _wrap({bool onboardingDone = false}) => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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

    testWidgets('page indicator shows 3 dots', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(OnboardingDot), findsNWidgets(3));
    });

    testWidgets('Continue opens profile setup with DK prefilled', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Set up your profile'), findsOneWidget);
      expect(find.text('DK'), findsOneWidget);
      expect(find.text('Aarav'), findsOneWidget);
      expect(find.text('Priya'), findsOneWidget);
    });

    testWidgets('selecting trainer and Get Started saves profile', (tester) async {
      final authRepo = FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            onboardingRepositoryProvider
                .overrideWithValue(FakeOnboardingRepository()),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Priya'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      final saved = await authRepo.getUser('member-dk-001');
      expect(saved?.name, 'DK');
      expect(saved?.assignedTrainerId, 'trainer-priya-001');
    });
  });
}
