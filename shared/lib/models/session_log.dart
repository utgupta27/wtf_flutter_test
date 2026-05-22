import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'session_log.g.dart';

@HiveType(typeId: 5)
class SessionLog extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final String trainerId;

  @HiveField(3)
  final DateTime startedAt;

  @HiveField(4)
  final DateTime endedAt;

  @HiveField(5)
  final int durationSec;

  @HiveField(6)
  final int? rating; // 1–5, set by member

  @HiveField(7)
  final String? trainerNotes;

  @HiveField(8)
  final String? memberNotes;

  const SessionLog({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  SessionLog copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    int? rating,
    String? trainerNotes,
    String? memberNotes,
  }) =>
      SessionLog(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        trainerId: trainerId ?? this.trainerId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        durationSec: durationSec ?? this.durationSec,
        rating: rating ?? this.rating,
        trainerNotes: trainerNotes ?? this.trainerNotes,
        memberNotes: memberNotes ?? this.memberNotes,
      );

  @override
  List<Object?> get props => [
        id,
        memberId,
        trainerId,
        startedAt,
        endedAt,
        durationSec,
        rating,
        trainerNotes,
        memberNotes,
      ];
}
