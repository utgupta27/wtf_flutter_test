import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shared/shared.dart';

import 'package:trainer_app/features/home/viewmodel/home_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(homeViewModelProvider);
    final name = authState.value?.name ?? 'Trainer';
    final unreadChats =
        ref.watch(totalUnreadChatProvider(ChatAppConfig.trainer()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $name 👋'),
        actions: [
          Chip(
            label: const Text('Trainer'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: HomeMessageSyncListener(
        config: ChatAppConfig.trainer(),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            const HomeActionTile(
              icon: Icons.video_call_rounded,
              label: 'Upcoming Calls',
              route: '/upcoming',
            ),
            HomeActionTile(
              icon: Icons.chat_bubble_rounded,
              label: 'Chats',
              route: '/chat',
              badgeCount: unreadChats,
            ),
            const HomeActionTile(
              icon: Icons.calendar_today_rounded,
              label: 'Requests',
              route: '/requests',
            ),
            const HomeActionTile(
              icon: Icons.fitness_center_rounded,
              label: 'Sessions',
              route: '/sessions',
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class HomeActionTile extends StatelessWidget {
  const HomeActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final String route;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              backgroundColor: const Color(0xFFE50914),
              smallSize: 10,
              child: Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
