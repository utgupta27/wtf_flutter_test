import 'package:shared/models/room_meta.dart';

extension RoomMetaJson on RoomMeta {
  Map<String, dynamic> toJson() => {
        'id': id,
        'callRequestId': callRequestId,
        'hmsRoomId': hmsRoomId,
        'hmsRoleMember': hmsRoleMember,
        'hmsRoleTrainer': hmsRoleTrainer,
      };

  static RoomMeta fromJson(Map<String, dynamic> json) => RoomMeta(
        id: json['id'] as String,
        callRequestId: json['callRequestId'] as String,
        hmsRoomId: json['hmsRoomId'] as String,
        hmsRoleMember: json['hmsRoleMember'] as String,
        hmsRoleTrainer: json['hmsRoleTrainer'] as String,
      );
}
