import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:guru_app/features/calls/providers/call_list_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider);
    final unreadChats =
        ref.watch(totalUnreadChatProvider(ChatAppConfig.member()));
    final nextUpcoming = ref.watch(nextUpcomingCallProvider);
    final pendingRequest = ref.watch(pendingCallRequestProvider);
    final hasUpcoming = nextUpcoming.valueOrNull != null;

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
            if (hasUpcoming)
              UpcomingCallHomeCard(call: nextUpcoming.valueOrNull!)
            else
              HomeActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Schedule Call',
                subtitle: 'Book your next session',
                color: const Color(0xFF7C3AED),
                onTap: () {
                  if (pendingRequest.valueOrNull != null) {
                    AppErrorSurface.showInfo(
                      context,
                      'A call request is already pending approval',
                    );
                    return;
                  }
                  context.push('/schedule');
                },
              ),
            if (!hasUpcoming) ...[
              const SizedBox(height: 16),
              const HomeActionCard(
                icon: Icons.video_call_rounded,
                title: 'Upcoming Calls',
                subtitle: 'Join when your session starts',
                route: '/upcoming',
                color: Color(0xFF0D9488),
              ),
            ],
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

/// Home preview of the next approved call; Join is enabled 10 min before start.
class UpcomingCallHomeCard extends StatelessWidget {
  const UpcomingCallHomeCard({super.key, required this.call});
  final CallRequest call;

  @override
  Widget build(BuildContext context) {
    final canJoin = SyncService.canJoinCall(call.scheduledFor);
    final timeLabel = DateFormat('EEE, MMM d · h:mm a').format(call.scheduledFor);
    final subtitle = canJoin
        ? 'Tap to join your session'
        : 'Join opens ${SyncConstants.joinWindowMinutes} min before start';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canJoin ? () => context.push('/call/${call.id}') : null,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  color: Color(0xFF0D9488),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              if (canJoin)
                FilledButton(
                  onPressed: () => context.push('/call/${call.id}'),
                  child: const Text('Join'),
                )
              else
                const Text('Soon', style: TextStyle(color: AppColors.subtle)),
            ],
          ),
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
    required this.color,
    this.route,
    this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
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
        onTap: onTap ?? (route != null ? () => context.push(route!) : null),
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
