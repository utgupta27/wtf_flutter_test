import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/state/chat_providers.dart';

/// Whether the chat peer is currently typing (from sync hub).
final peerTypingProvider = Provider.family<bool, PeerTypingParams>((ref, params) {
  ref.watch(sharedSyncTickProvider);
  final sync = ref.watch(sharedSyncServiceProvider);
  final presence = sync.getPeerTyping(params.peerUserId);
  if (presence == null || !presence.isTyping) {
    return false;
  }
  return presence.chatId == params.chatId;
});

class PeerTypingParams {
  const PeerTypingParams({required this.chatId, required this.peerUserId});
  final String chatId;
  final String peerUserId;

  @override
  bool operator ==(Object other) =>
      other is PeerTypingParams &&
      chatId == other.chatId &&
      peerUserId == other.peerUserId;

  @override
  int get hashCode => Object.hash(chatId, peerUserId);
}

PeerTypingParams peerTypingParams(ChatAppConfig config, String chatId) =>
    PeerTypingParams(chatId: chatId, peerUserId: config.peerUserId);
