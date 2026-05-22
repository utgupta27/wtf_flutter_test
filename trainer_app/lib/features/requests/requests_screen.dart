import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/requests/viewmodel/requests_viewmodel.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(requestsViewModelProvider);
    final vm = ref.read(requestsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          final pending = requests
              .where((r) => r.status == CallRequestStatus.pending)
              .toList();
          final approved = requests
              .where((r) => r.status == CallRequestStatus.approved)
              .toList();

          if (pending.isEmpty && approved.isEmpty) {
            return const Center(child: Text('No requests'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                const Text(
                  'Pending',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...pending.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RequestCard(
                      request: r,
                      onApprove: () => vm.approve(r.id),
                      onDecline: () => _showDeclineDialog(context, vm, r.id),
                    ),
                  ),
                ),
              ],
              if (approved.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Approved',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...approved.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ApprovedRequestCard(request: r),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Future<void> _showDeclineDialog(
  BuildContext context,
  RequestsViewModel vm,
  String requestId,
) async {
  final controller = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Decline request'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Reason (required)'),
        maxLines: 2,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(ctx, text);
          },
          child: const Text('Decline'),
        ),
      ],
    ),
  );
  if (reason != null && context.mounted) {
    await vm.decline(requestId, reason: reason);
  }
}

class ApprovedRequestCard extends StatelessWidget {
  const ApprovedRequestCard({super.key, required this.request});
  final CallRequest request;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('EEE, MMM d · h:mm a').format(request.scheduledFor);
    final canJoin = SyncService.canJoinCall(request.scheduledFor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Text('DK')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DK', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(time, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Chip(label: Text('Approved')),
              ],
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.note),
            ],
            const SizedBox(height: 12),
            if (canJoin)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/call/${request.id}'),
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Join Call'),
                ),
              )
            else
              Text(
                'Join opens 10 minutes before the scheduled time',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onDecline,
  });

  final CallRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final scheduledStr =
        DateFormat('EEE d MMM · h:mm a').format(request.scheduledFor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Text('DK')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DK',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        scheduledStr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                request.note,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final CallRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CallRequestStatus.pending => ('Pending', Colors.orange),
      CallRequestStatus.approved => ('Approved', Colors.green),
      CallRequestStatus.declined => ('Declined', Colors.red),
      CallRequestStatus.cancelled => ('Cancelled', Colors.grey),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: EdgeInsets.zero,
    );
  }
}
