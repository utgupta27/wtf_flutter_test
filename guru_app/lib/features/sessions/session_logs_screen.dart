import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';
import 'package:guru_app/features/sessions/viewmodel/session_logs_viewmodel.dart';

class SessionLogsScreen extends ConsumerWidget {
  const SessionLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(sessionLogsViewModelProvider);
    final vm = ref.read(sessionLogsViewModelProvider.notifier);

    return GuruSubpageScaffold(
      title: const Text('My Sessions'),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final hasSessions = state.filtered.isNotEmpty;
          final hasMissed = state.missedCalls.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterRow(
                selected: state.filter,
                onSelect: vm.setFilter,
              ),
              Expanded(
                child: (!hasSessions && !hasMissed)
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: vm.refresh,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (hasSessions) ...[
                              ...state.filtered
                                  .map((l) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: SessionLogTile(log: l),
                                      )),
                            ],
                            if (hasMissed) ...[
                              if (hasSessions) const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Missed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              ...state.missedCalls.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _MissedCallTile(request: r),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelect});
  final SessionFilter selected;
  final void Function(SessionFilter) onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: SessionFilter.values.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_label(f)),
              selected: selected == f,
              onSelected: (_) => onSelect(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(SessionFilter f) => switch (f) {
        SessionFilter.all => 'All',
        SessionFilter.last7d => 'Last 7 days',
        SessionFilter.thisMonth => 'This Month',
      };
}

class SessionLogTile extends StatelessWidget {
  const SessionLogTile({super.key, required this.log});
  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM · h:mm a').format(log.startedAt);
    final durationMin = (log.durationSec / 60).ceil();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.fitness_center_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session with Aarav',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$durationMin min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (log.rating != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    '${log.rating}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MissedCallTile extends StatelessWidget {
  const _MissedCallTile({required this.request});
  final CallRequest request;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEE, d MMM · h:mm a').format(request.scheduledFor);
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.event_busy_rounded, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Missed session with Aarav',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (request.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.note,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Chip(
              label: Text('Missed', style: TextStyle(fontSize: 11)),
              backgroundColor: Color(0x1AFF9800),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text('No sessions yet'),
          ],
        ),
      );
}
