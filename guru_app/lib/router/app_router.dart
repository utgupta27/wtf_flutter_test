import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:guru_app/features/calls/schedule_call_screen.dart';
import 'package:guru_app/features/calls/video_call_screen.dart';
import 'package:guru_app/features/sessions/session_logs_screen.dart';
import 'package:guru_app/features/chat/chat_list_screen.dart';
import 'package:guru_app/features/chat/conversation_screen.dart';
import 'package:guru_app/features/home/home_screen.dart';
import 'package:guru_app/features/onboarding/onboarding_screen.dart';
import 'package:guru_app/features/onboarding/viewmodel/onboarding_viewmodel.dart';

/// Pure redirect logic — used by GoRouter and unit tests.
String? resolveGuruRedirect({
  required AsyncValue<User> authState,
  required bool onboardingDone,
  required String matchedLocation,
}) {
  if (authState.isLoading) {
    return '/splash';
  }
  if (!onboardingDone && matchedLocation != '/onboarding') {
    return '/onboarding';
  }
  if (onboardingDone && matchedLocation == '/onboarding') {
    return '/home';
  }
  if (onboardingDone && matchedLocation == '/splash') {
    return '/home';
  }
  return null;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'Loading…',
              style: TextStyle(fontSize: 16, color: AppColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final onboardingDone = ref.read(onboardingViewModelProvider);
      return resolveGuruRedirect(
        authState: authState,
        onboardingDone: onboardingDone,
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':chatId',
            builder: (context, state) => ConversationScreen(
              chatId: state.pathParameters['chatId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleCallScreen(),
      ),
      GoRoute(
        path: '/call/:requestId',
        builder: (context, state) => VideoCallScreen(
          requestId: state.pathParameters['requestId']!,
        ),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionLogsScreen(),
      ),
    ],
  );

  ref.listen(authViewModelProvider, (_, _) => router.refresh());
  ref.listen(onboardingViewModelProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
