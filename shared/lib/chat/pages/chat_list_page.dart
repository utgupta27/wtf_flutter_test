import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/state/chat_list_viewmodel.dart';
import 'package:shared/chat/state/chat_providers.dart';
import 'package:shared/chat/widgets/chat_empty_state.dart';
import 'package:shared/chat/widgets/home_message_sync_listener.dart';
import 'package:shared/chat/widgets/chat_list_tile.dart';
import 'package:shared/constants/sync_constants.dart';

/// Shared chat list body; app supplies scaffold wrapper.
class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({
    super.key,
    required this.config,
    required this.onOpenChat,
    this.emptySubtitle,
  });

  final ChatAppConfig config;
  final void Function(String chatId) onOpenChat;
  final String? emptySubtitle;

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageSyncServiceProvider).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sharedSyncTickProvider, (_, __) {
      ref.invalidate(chatListViewModelProvider(widget.config));
    });

    final state = ref.watch(chatListViewModelProvider(widget.config));
    final vm = ref.read(chatListViewModelProvider(widget.config).notifier);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (conversations) => conversations.isEmpty
          ? ChatEmptyState(
              subtitle: widget.emptySubtitle ??
                  'Say hi to your ${widget.config.role == ChatRole.member ? 'trainer' : 'member'} to get started',
              onSayHi: () => widget.onOpenChat(SyncConstants.defaultChatId),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(messageSyncServiceProvider).syncNow();
                await vm.refresh();
              },
              child: ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 80),
                itemBuilder: (context, index) {
                  final preview = conversations[index];
                  return ChatListTile(
                    preview: preview,
                    peerColor: widget.config.peerBubbleColor,
                    onTap: () => widget.onOpenChat(preview.chatId),
                  );
                },
              ),
            ),
    );
  }
}
