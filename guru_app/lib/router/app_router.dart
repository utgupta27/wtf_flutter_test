import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guru_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:guru_app/features/chat/chat_list_screen.dart';
import 'package:guru_app/features/chat/conversation_screen.dart';
import 'package:guru_app/features/home/home_screen.dart';
import 'package:guru_app/features/onboarding/onboarding_screen.dart';
import 'package:guru_app/features/onboarding/viewmodel/onboarding_viewmodel.dart';

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
  final authState = ref.watch(authViewModelProvider);
  final onboardingDone = ref.watch(onboardingViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) {
        return '/splash';
      }
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
        builder: (context, state) => const _PlaceholderScreen(''),
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
        builder: (context, state) => const _PlaceholderScreen('Schedule Call'),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const _PlaceholderScreen('Session Logs'),
      ),
    ],
  );
});
