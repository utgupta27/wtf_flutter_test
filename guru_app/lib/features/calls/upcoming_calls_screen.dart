import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';
import 'package:guru_app/features/calls/viewmodel/upcoming_calls_viewmodel.dart';

class UpcomingCallsScreen extends ConsumerWidget {
  const UpcomingCallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(upcomingCallsViewModelProvider);

    return GuruSubpageScaffold(
      title: const Text('Upcoming Calls'),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (calls) {
          if (calls.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming calls',
                style: TextStyle(color: AppColors.subtle),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: calls.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = calls[i];
              final canJoin = SyncService.canJoinCall(item.scheduledFor);
              return Card(
                child: ListTile(
                  title: Text(
                    DateFormat('EEE, MMM d · h:mm a').format(item.scheduledFor),
                  ),
                  subtitle: Text(item.note.isEmpty ? 'Session with Aarav' : item.note),
                  trailing: canJoin
                      ? FilledButton(
                          onPressed: () => context.push('/call/${item.id}'),
                          child: const Text('Join'),
                        )
                      : const Text('Soon', style: TextStyle(color: AppColors.subtle)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
