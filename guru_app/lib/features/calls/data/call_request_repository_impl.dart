import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/calls/data/call_request_repository.dart';

class HiveCallRequestRepository implements CallRequestRepository {
  HiveCallRequestRepository(this._box);
  final Box _box;

  @override
  Future<List<CallRequest>> getAll() async =>
      _box.values.cast<CallRequest>().toList();

  @override
  Future<CallRequest?> getById(String id) async =>
      _box.get(id) as CallRequest?;

  @override
  Future<void> save(CallRequest request) async =>
      _box.put(request.id, request);

  @override
  Future<void> updateStatus(String id, CallRequestStatus status) async {
    final existing = _box.get(id) as CallRequest?;
    if (existing != null) {
      await _box.put(id, existing.copyWith(status: status));
    }
  }

  @override
  Future<bool> hasConflict(DateTime scheduledFor, String trainerId) async =>
      _box.values.cast<CallRequest>().any(
            (r) =>
                r.trainerId == trainerId &&
                r.scheduledFor == scheduledFor &&
                r.status == CallRequestStatus.approved,
          );
}
