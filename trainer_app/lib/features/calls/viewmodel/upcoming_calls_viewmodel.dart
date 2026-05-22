import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';
import 'package:trainer_app/providers/sync_provider.dart';

final upcomingCallsViewModelProvider =
    AsyncNotifierProvider<UpcomingCallsViewModel, List<CallRequest>>(
  UpcomingCallsViewModel.new,
);

class UpcomingCallsViewModel extends AsyncNotifier<List<CallRequest>> {
  @override
  Future<List<CallRequest>> build() async {
    ref.listen(syncTickProvider, (prev, next) {
      ref.invalidateSelf();
    });
    final all = await ref.read(callRequestRepositoryProvider).getAll();
    return all
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              !SyncService.isCallExpired(r.scheduledFor),
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  }
}
