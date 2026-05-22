import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/requests/data/call_request_repository.dart';

class HiveCallRequestRepository implements CallRequestRepository {
  HiveCallRequestRepository(this._box);
  final Box<dynamic> _box;

  static CallRequest _parseRequest(dynamic raw) {
    if (raw is CallRequest) {
      return raw;
    }
    return CallRequestJson.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<List<CallRequest>> getAll() async {
    final all = _box.values.map(_parseRequest).toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return all;
  }

  @override
  Future<void> updateStatus(String id, CallRequestStatus status) async {
    final raw = _box.get(id);
    if (raw == null) {
      return;
    }
    final existing = _parseRequest(raw);
    await _box.put(id, existing.copyWith(status: status));
  }
}
