import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/requests/data/call_request_repository.dart';

class HiveCallRequestRepository implements CallRequestRepository {
  HiveCallRequestRepository(this._box);
  final Box _box;

  @override
  Future<List<CallRequest>> getAll() async =>
      _box.values.cast<CallRequest>().toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  @override
  Future<void> updateStatus(String id, CallRequestStatus status) async {
    final existing = _box.get(id) as CallRequest?;
    if (existing != null) {
      await _box.put(id, existing.copyWith(status: status));
    }
  }
}
