import 'package:flutter/material.dart';
import 'package:shared/chat/config/chat_theme.dart';
import 'package:shared/constants/sync_constants.dart';
import 'package:shared/models/user.dart';

enum ChatRole { member, trainer }

/// Per-app chat identity and bubble colors.
class ChatAppConfig {
  const ChatAppConfig({
    required this.role,
    required this.localUserId,
    required this.peerUserId,
    required this.peerDisplayName,
    required this.myBubbleColor,
    required this.peerBubbleColor,
    this.peerAvatarLetter,
  });

  final ChatRole role;
  final String localUserId;
  final String peerUserId;
  final String peerDisplayName;
  final Color myBubbleColor;
  final Color peerBubbleColor;
  final String? peerAvatarLetter;

  factory ChatAppConfig.member() => ChatAppConfig(
        role: ChatRole.member,
        localUserId: SyncConstants.memberId,
        peerUserId: SyncConstants.trainerId,
        peerDisplayName: SeedUsers.trainer.name,
        myBubbleColor: ChatTheme.memberBlue,
        peerBubbleColor: ChatTheme.trainerRed,
        peerAvatarLetter: SeedUsers.trainer.name.isNotEmpty
            ? SeedUsers.trainer.name[0]
            : 'T',
      );

  factory ChatAppConfig.trainer() => ChatAppConfig(
        role: ChatRole.trainer,
        localUserId: SyncConstants.trainerId,
        peerUserId: SyncConstants.memberId,
        peerDisplayName: SeedUsers.member.name,
        myBubbleColor: ChatTheme.trainerRed,
        peerBubbleColor: ChatTheme.memberBlue,
        peerAvatarLetter: SeedUsers.member.name.isNotEmpty
            ? SeedUsers.member.name[0]
            : 'M',
      );

  bool isMine(String senderId) => senderId == localUserId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAppConfig &&
          role == other.role &&
          localUserId == other.localUserId;

  @override
  int get hashCode => Object.hash(role, localUserId);
}
