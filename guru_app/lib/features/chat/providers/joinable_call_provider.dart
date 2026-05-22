import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';

/// Approved call that is within the join window (dev: 1 min).
final joinableCallRequestProvider = FutureProvider<CallRequest?>((ref) async {
  ref.watch(syncTickProvider);
  final all = await ref.read(callRequestRepositoryProvider).getAll();
  for (final r in all) {
    if (r.status == CallRequestStatus.approved &&
        SyncService.canJoinCall(r.scheduledFor)) {
      return r;
    }
  }
  return null;
});
