import 'package:shared/shared.dart';

abstract interface class SessionLogRepository {
  Future<List<SessionLog>> getAll();
  Future<void> save(SessionLog log);
  Future<void> addTrainerNote(String id, String note);
}
