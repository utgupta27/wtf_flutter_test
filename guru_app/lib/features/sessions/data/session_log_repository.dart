import 'package:shared/shared.dart';

abstract interface class SessionLogRepository {
  Future<List<SessionLog>> getAll();
  Future<void> save(SessionLog log);
}
