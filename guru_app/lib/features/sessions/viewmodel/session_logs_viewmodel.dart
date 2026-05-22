import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';

enum SessionFilter { all, last7d, thisMonth }

class SessionLogsState {
  const SessionLogsState({
    this.filter = SessionFilter.all,
    this.logs = const [],
  });

  final SessionFilter filter;
  final List<SessionLog> logs;

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
  }) =>
      SessionLogsState(
        filter: filter ?? this.filter,
        logs: logs ?? this.logs,
      );
}

class SessionLogsViewModel extends AsyncNotifier<SessionLogsState> {
  @override
  Future<SessionLogsState> build() async {
    final logs = await ref.read(sessionLogRepositoryProvider).getAll();
    return SessionLogsState(logs: logs);
  }

  void setFilter(SessionFilter filter) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(filter: filter));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final logs = await ref.read(sessionLogRepositoryProvider).getAll();
      return SessionLogsState(logs: logs);
    });
  }
}

final sessionLogsViewModelProvider =
    AsyncNotifierProvider<SessionLogsViewModel, SessionLogsState>(
  SessionLogsViewModel.new,
);
