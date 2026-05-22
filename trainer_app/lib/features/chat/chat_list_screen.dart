import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Trainer shell around shared [ChatListPage].
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static final _config = ChatAppConfig.trainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadChatProvider(_config));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Chats'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              const ChatRedDot(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/${SyncConstants.defaultChatId}'),
        child: const Icon(Icons.add),
      ),
      body: ChatListPage(
        config: _config,
        onOpenChat: (id) => context.push('/chat/$id'),
        emptySubtitle: 'Say hi to your member to get started',
      ),
    );
  }
}
