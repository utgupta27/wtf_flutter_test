import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trainer_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:trainer_app/features/chat/chat_list_screen.dart';
import 'package:trainer_app/features/chat/conversation_screen.dart';
import 'package:trainer_app/features/home/home_screen.dart';
import 'package:trainer_app/features/calls/video_call_screen.dart';
import 'package:trainer_app/features/requests/requests_screen.dart';
import 'package:trainer_app/features/sessions/session_logs_screen.dart';

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

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';
      return state.matchedLocation == '/splash' ? '/home' : null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/members',
        builder: (context, state) => const _PlaceholderScreen('Members'),
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
        path: '/requests',
        builder: (context, state) => const RequestsScreen(),
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
});
