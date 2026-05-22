import 'package:shared/shared.dart';

abstract interface class CallRequestRepository {
  Future<List<CallRequest>> getAll();
  Future<CallRequest?> getById(String id);
  Future<void> save(CallRequest request);
  Future<void> updateStatus(String id, CallRequestStatus status);
  Future<bool> hasConflict(DateTime scheduledFor, String trainerId);
}
