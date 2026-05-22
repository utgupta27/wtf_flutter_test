import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class SessionLogsViewModel extends AsyncNotifier<List<SessionLog>> {
  @override
  Future<List<SessionLog>> build() async =>
      ref.read(sessionLogRepositoryProvider).getAll();

  Future<void> addNote(String logId, String note) async {
    await ref.read(sessionLogRepositoryProvider).addTrainerNote(logId, note);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(sessionLogRepositoryProvider).getAll(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(sessionLogRepositoryProvider).getAll(),
    );
  }
}

final sessionLogsViewModelProvider =
    AsyncNotifierProvider<SessionLogsViewModel, List<SessionLog>>(
  SessionLogsViewModel.new,
);
