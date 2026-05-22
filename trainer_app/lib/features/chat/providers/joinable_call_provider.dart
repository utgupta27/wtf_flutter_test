import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';
import 'package:trainer_app/providers/sync_provider.dart';

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
