import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';

enum SessionFilter { all, last7d, thisMonth }

class SessionLogsState {
  const SessionLogsState({
    this.filter = SessionFilter.all,
    this.logs = const [],
    this.missedCalls = const [],
  });

  final SessionFilter filter;
  final List<SessionLog> logs;

  /// Approved call requests whose join window has fully expired and were never logged.
  final List<CallRequest> missedCalls;

  List<SessionLog> get filtered {
    final now = DateTime.now();
    return switch (filter) {
      SessionFilter.all => logs,
      SessionFilter.last7d => logs
          .where((l) => l.startedAt
              .isAfter(now.subtract(const Duration(days: 7))))
          .toList(),
      SessionFilter.thisMonth => logs
          .where((l) =>
              l.startedAt.year == now.year && l.startedAt.month == now.month)
          .toList(),
    };
  }

  SessionLogsState copyWith({
    SessionFilter? filter,
    List<SessionLog>? logs,
    List<CallRequest>? missedCalls,
  }) =>
      SessionLogsState(
        filter: filter ?? this.filter,
        logs: logs ?? this.logs,
        missedCalls: missedCalls ?? this.missedCalls,
      );
}

class SessionLogsViewModel extends AsyncNotifier<SessionLogsState> {
  @override
  Future<SessionLogsState> build() async {
    ref.listen(syncTickProvider, (prev, next) {
      ref.invalidateSelf();
    });
    return _load();
  }

  Future<SessionLogsState> _load() async {
    final logs = await ref.read(sessionLogRepositoryProvider).getAll();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Find approved calls whose window expired but have no matching session log.
    final loggedRequestIds =
        logs.map((l) => l.id.split('-').take(2).join('-')).toSet();
    final allRequests = await ref.read(callRequestRepositoryProvider).getAll();
    final missed = allRequests
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              SyncService.isCallExpired(r.scheduledFor) &&
              !loggedRequestIds.any((id) => id.startsWith(r.id)),
        )
        .toList()
      ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return SessionLogsState(logs: logs, missedCalls: missed);
  }

  void setFilter(SessionFilter filter) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(filter: filter));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final sessionLogsViewModelProvider =
    AsyncNotifierProvider<SessionLogsViewModel, SessionLogsState>(
  SessionLogsViewModel.new,
);
