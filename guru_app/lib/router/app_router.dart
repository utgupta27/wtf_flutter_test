import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/auth/auth_provider.dart';
import 'package:guru_app/features/chat/conversation_screen.dart';
import 'package:guru_app/features/home/home_screen.dart';
import 'package:guru_app/features/onboarding/onboarding_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title)),
      );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      if (authState.isLoading) {
        return '/splash';
      }
      final settingsBox = Hive.box(AppConstants.hiveBoxSettings);
      final onboardingDone =
          settingsBox.get(AppConstants.settingsKeyOnboardingDone, defaultValue: false) as bool;

      if (!onboardingDone && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingDone && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _PlaceholderScreen('Splash'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          onComplete: () {
            Hive.box(AppConstants.hiveBoxSettings)
                .put(AppConstants.settingsKeyOnboardingDone, true);
            context.go('/home');
          },
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => ConversationScreen(
          currentUserId: SeedUsers.member.id,
          otherUserName: SeedUsers.trainer.name,
          messages: const [],
          onSend: (_) {},
        ),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const _PlaceholderScreen('Schedule Call'),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const _PlaceholderScreen('Session Logs'),
      ),
    ],
  );
});
