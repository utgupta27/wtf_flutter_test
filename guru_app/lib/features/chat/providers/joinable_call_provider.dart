import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/calls/providers/call_list_providers.dart';

/// Approved call that is within the join window (10 min before start).
final joinableCallRequestProvider = FutureProvider<CallRequest?>((ref) async {
  final upcoming = await ref.watch(upcomingApprovedCallsProvider.future);
  for (final r in upcoming) {
    if (SyncService.canJoinCall(r.scheduledFor)) {
      return r;
    }
  }
  return null;
});
