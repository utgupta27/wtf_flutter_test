import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/features/auth/viewmodel/auth_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider);
    final unreadChats =
        ref.watch(totalUnreadChatProvider(ChatAppConfig.member()));
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Hi, ${user.valueOrNull?.name ?? '...'} 👋'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: HomeMessageSyncListener(
        config: ChatAppConfig.member(),
        child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          HomeActionCard(
            icon: Icons.chat_bubble_rounded,
            title: 'Chat with Trainer',
            subtitle: unreadChats > 0
                ? '$unreadChats unread message${unreadChats == 1 ? '' : 's'}'
                : 'Message Aarav anytime',
            route: '/chat/${AppConstants.defaultChatId}',
            color: const Color(0xFF1769E0),
            badgeCount: unreadChats,
          ),
          const SizedBox(height: 16),
          const HomeActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Schedule Call',
            subtitle: 'Book your next session',
            route: '/schedule',
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 16),
          const HomeActionCard(
            icon: Icons.video_call_rounded,
            title: 'Upcoming Calls',
            subtitle: 'Join when your session starts',
            route: '/upcoming',
            color: Color(0xFF0D9488),
          ),
          const SizedBox(height: 16),
          const HomeActionCard(
            icon: Icons.bar_chart_rounded,
            title: 'My Sessions',
            subtitle: 'View past sessions and ratings',
            route: '/sessions',
            color: Color(0xFF059669),
          ),
        ],
      ),
      ),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                backgroundColor: AppColors.trainerPrimary,
                smallSize: 10,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}
