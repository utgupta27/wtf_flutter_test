import 'package:shared/models/session_log.dart';

extension SessionLogJson on SessionLog {
  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSec': durationSec,
        'rating': rating,
        'trainerNotes': trainerNotes,
        'memberNotes': memberNotes,
      };

  static SessionLog fromJson(Map<String, dynamic> json) => SessionLog(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        trainerId: json['trainerId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        durationSec: json['durationSec'] as int,
        rating: json['rating'] as int?,
        trainerNotes: json['trainerNotes'] as String?,
        memberNotes: json['memberNotes'] as String?,
      );
}
