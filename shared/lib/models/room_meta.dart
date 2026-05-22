import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'room_meta.g.dart';

@HiveType(typeId: 6)
class RoomMeta extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String callRequestId;

  @HiveField(2)
  final String hmsRoomId;

  @HiveField(3)
  final String hmsRoleMember;

  @HiveField(4)
  final String hmsRoleTrainer;

  const RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  @override
  List<Object?> get props =>
      [id, callRequestId, hmsRoomId, hmsRoleMember, hmsRoleTrainer];
}
