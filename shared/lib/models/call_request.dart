import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'call_request.g.dart';

@HiveType(typeId: 3)
enum CallRequestStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  declined,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 4)
class CallRequest extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final String trainerId;

  @HiveField(3)
  final DateTime requestedAt;

  @HiveField(4)
  final DateTime scheduledFor;

  @HiveField(5)
  final String note;

  @HiveField(6)
  final CallRequestStatus status;

  const CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.requestedAt,
    required this.scheduledFor,
    required this.note,
    this.status = CallRequestStatus.pending,
  });

  CallRequest copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? requestedAt,
    DateTime? scheduledFor,
    String? note,
    CallRequestStatus? status,
  }) =>
      CallRequest(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        trainerId: trainerId ?? this.trainerId,
        requestedAt: requestedAt ?? this.requestedAt,
        scheduledFor: scheduledFor ?? this.scheduledFor,
        note: note ?? this.note,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [id, memberId, trainerId, requestedAt, scheduledFor, note, status];
}
