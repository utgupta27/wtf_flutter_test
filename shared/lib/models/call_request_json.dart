import 'package:shared/models/call_request.dart';

/// JSON helpers for Node sync API (status as string names).
extension CallRequestJson on CallRequest {
  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'requestedAt': requestedAt.toIso8601String(),
        'scheduledFor': scheduledFor.toIso8601String(),
        'note': note,
        'status': status.name,
      };

  static CallRequest fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String;
    return CallRequest(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      note: json['note'] as String? ?? '',
      status: CallRequestStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => CallRequestStatus.pending,
      ),
    );
  }
}
