import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/sessions/viewmodel/session_logs_viewmodel.dart';

class SessionLogsScreen extends ConsumerWidget {
  const SessionLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(sessionLogsViewModelProvider);
    final vm = ref.read(sessionLogsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('No sessions yet'))
            : RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) => SessionLogTile(
                    log: logs[i],
                    onAddNote: (note) => vm.addNote(logs[i].id, note),
                  ),
                ),
              ),
      ),
    );
  }
}

class SessionLogTile extends StatelessWidget {
  const SessionLogTile({
    super.key,
    required this.log,
    required this.onAddNote,
  });

  final SessionLog log;
  final void Function(String) onAddNote;

  String _formatDate(DateTime dt) =>
      DateFormat('EEE, d MMM · h:mm a').format(dt);

  String _formatDuration(int sec) {
    final m = (sec / 60).ceil();
    return '$m min';
  }

  void _showNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: log.trainerNotes ?? '');
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Trainer Notes'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: 'Add notes about this session…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onAddNote(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        'Session with DK',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatDate(log.startedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDuration(log.durationSec),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (log.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        '${log.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),
            if (log.trainerNotes != null && log.trainerNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.trainerNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showNoteDialog(context),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(
                log.trainerNotes == null || log.trainerNotes!.isEmpty
                    ? 'Add note'
                    : 'Edit note',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
