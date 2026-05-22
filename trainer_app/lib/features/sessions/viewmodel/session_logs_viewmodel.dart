import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';
import 'package:trainer_app/providers/sync_provider.dart';

class TrainerSessionState {
  const TrainerSessionState({
    this.logs = const [],
    this.missedCalls = const [],
  });
  final List<SessionLog> logs;
  final List<CallRequest> missedCalls;
}

class SessionLogsViewModel extends AsyncNotifier<TrainerSessionState> {
  @override
  Future<TrainerSessionState> build() async {
    ref.listen(syncTickProvider, (prev, next) {
      ref.invalidateSelf();
    });
    return _load();
  }

  Future<TrainerSessionState> _load() async {
    final logs = await ref.read(sessionLogRepositoryProvider).getAll();
    logs.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final allRequests = await ref.read(callRequestRepositoryProvider).getAll();
    final missed = allRequests
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              SyncService.isCallExpired(r.scheduledFor) &&
              !logs.any((l) => l.id.startsWith(r.id)),
        )
        .toList()
      ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return TrainerSessionState(logs: logs, missedCalls: missed);
  }

  Future<void> addNote(String logId, String note) async {
    await ref.read(sessionLogRepositoryProvider).addTrainerNote(logId, note);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final sessionLogsViewModelProvider =
    AsyncNotifierProvider<SessionLogsViewModel, TrainerSessionState>(
  SessionLogsViewModel.new,
);
