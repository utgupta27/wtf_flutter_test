import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/app.dart';
import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/router/app_router.dart';
import '../fakes/fake_repositories.dart';

void main() {
  group('resolveGuruRedirect', () {
    test('auth loading keeps splash', () {
      expect(
        resolveGuruRedirect(
          authState: const AsyncValue.loading(),
          onboardingDone: false,
          matchedLocation: '/splash',
        ),
        '/splash',
      );
    });

    test('onboarding incomplete sends non-onboarding routes to onboarding', () {
      expect(
        resolveGuruRedirect(
          authState: const AsyncData(SeedUsers.member),
          onboardingDone: false,
          matchedLocation: '/home',
        ),
        '/onboarding',
      );
    });

    test('onboarding complete on splash sends to home', () {
      expect(
        resolveGuruRedirect(
          authState: const AsyncData(SeedUsers.member),
          onboardingDone: true,
          matchedLocation: '/splash',
        ),
        '/home',
      );
    });

    test('onboarding complete on onboarding sends to home', () {
      expect(
        resolveGuruRedirect(
          authState: const AsyncData(SeedUsers.member),
          onboardingDone: true,
          matchedLocation: '/onboarding',
        ),
        '/home',
      );
    });

    test('onboarding complete on home stays', () {
      expect(
        resolveGuruRedirect(
          authState: const AsyncData(SeedUsers.member),
          onboardingDone: true,
          matchedLocation: '/home',
        ),
        isNull,
      );
    });
  });

  group('GuruApp routing', () {
    testWidgets('opens home when onboarding already done', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            onboardingRepositoryProvider
                .overrideWithValue(FakeOnboardingRepository(done: true)),
          ],
          child: const GuruApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chat with Trainer'), findsOneWidget);
      expect(find.text('Schedule Call'), findsOneWidget);
      expect(find.text('My Sessions'), findsOneWidget);
    });

    testWidgets('Get Started navigates to home with three cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            onboardingRepositoryProvider
                .overrideWithValue(FakeOnboardingRepository()),
          ],
          child: const GuruApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome to WTF'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Set up your profile'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Chat with Trainer'), findsOneWidget);
      expect(find.text('Hi, DK 👋'), findsOneWidget);
    });
  });
}
