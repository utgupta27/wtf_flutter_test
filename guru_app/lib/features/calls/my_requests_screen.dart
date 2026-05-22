import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';
import 'package:guru_app/features/calls/viewmodel/my_requests_viewmodel.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myRequestsViewModelProvider);

    return GuruSubpageScaffold(
      title: const Text('My Requests'),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No call requests yet',
                style: TextStyle(color: AppColors.subtle),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = requests[i];
              return _RequestTile(request: r);
            },
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});
  final CallRequest request;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('EEE, MMM d · h:mm a').format(request.scheduledFor);
    final statusLabel = switch (request.status) {
      CallRequestStatus.pending => UiCopy.callRequestedWaiting,
      CallRequestStatus.approved => 'Approved',
      CallRequestStatus.declined => 'Declined',
      CallRequestStatus.cancelled => 'Cancelled',
    };
    final statusColor = switch (request.status) {
      CallRequestStatus.pending => AppColors.warning,
      CallRequestStatus.approved => AppColors.success,
      CallRequestStatus.declined => AppColors.error,
      CallRequestStatus.cancelled => AppColors.subtle,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.note, style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 8),
            Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
