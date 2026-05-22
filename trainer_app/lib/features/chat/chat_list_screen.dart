import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trainer_app/features/chat/viewmodel/chat_list_viewmodel.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(chatListViewModelProvider);
    final vm = ref.read(chatListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (previews) => previews.isEmpty
            ? const Center(child: Text('No conversations yet'))
            : RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView.separated(
                  itemCount: previews.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) => ChatListTile(
                    preview: previews[i],
                    onTap: () => context.push('/chat/${previews[i].chatId}'),
                  ),
                ),
              ),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.preview, required this.onTap});
  final ChatPreview preview;
  final VoidCallback onTap;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Text('DK')),
      title: Text(
        preview.memberName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        preview.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(preview.lastTime),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (preview.hasUnread) ...[
            const SizedBox(height: 4),
            const UnreadBadge(),
          ],
        ],
      ),
    );
  }
}

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      );
}
