import 'package:shared/shared.dart';

abstract interface class CallRequestRepository {
  Future<List<CallRequest>> getAll();
  Future<void> updateStatus(String id, CallRequestStatus status);
}
