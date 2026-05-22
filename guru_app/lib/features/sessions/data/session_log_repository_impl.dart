import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/sessions/data/session_log_repository.dart';

class HiveSessionLogRepository implements SessionLogRepository {
  HiveSessionLogRepository(this._box);
  final Box _box;

  @override
  Future<List<SessionLog>> getAll() async =>
      _box.values.cast<SessionLog>().toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Future<void> save(SessionLog log) async => _box.put(log.id, log);
}
