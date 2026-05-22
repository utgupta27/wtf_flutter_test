import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';

/// Approved calls that are still within the join window (not expired).
List<CallRequest> filterUpcomingApprovedCalls(List<CallRequest> all) {
  final upcoming = all
      .where(
        (r) =>
            r.status == CallRequestStatus.approved &&
            !SyncService.isCallExpired(r.scheduledFor),
      )
      .toList();
  upcoming.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  return upcoming;
}

/// All approved, non-expired upcoming calls (refreshes on sync ticks).
final upcomingApprovedCallsProvider =
    FutureProvider<List<CallRequest>>((ref) async {
  ref.watch(syncTickProvider);
  final all = await ref.read(callRequestRepositoryProvider).getAll();
  return filterUpcomingApprovedCalls(all);
});

/// Earliest approved upcoming call for home preview.
final nextUpcomingCallProvider = FutureProvider<CallRequest?>((ref) async {
  final upcoming = await ref.watch(upcomingApprovedCallsProvider.future);
  if (upcoming.isEmpty) {
    return null;
  }
  return upcoming.first;
});

/// Pending request that blocks scheduling another call.
final pendingCallRequestProvider = FutureProvider<CallRequest?>((ref) async {
  ref.watch(syncTickProvider);
  final all = await ref.read(callRequestRepositoryProvider).getAll();
  for (final r in all) {
    if (r.status == CallRequestStatus.pending) {
      return r;
    }
  }
  return null;
});
