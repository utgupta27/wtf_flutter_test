import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/state/chat_list_viewmodel.dart';

/// Total unread inbound messages for home badge (requires [chatListViewModelProvider] watch).
final totalUnreadChatProvider = Provider.family<int, ChatAppConfig>((ref, config) {
  final previews = ref.watch(chatListViewModelProvider(config)).valueOrNull;
  if (previews == null) {
    return 0;
  }
  var total = 0;
  for (final preview in previews) {
    total += preview.unreadCount;
  }
  return total;
});
