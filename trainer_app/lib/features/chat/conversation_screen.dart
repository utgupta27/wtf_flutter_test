import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/chat/viewmodel/conversation_viewmodel.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(conversationViewModelProvider(widget.chatId));
    final vm = ref.read(conversationViewModelProvider(widget.chatId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('DK')),
      body: Column(
        children: [
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (state) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.messages.length,
                itemBuilder: (context, i) =>
                    _ChatBubble(message: state.messages[i]),
              ),
            ),
          ),
          _InputBar(
            controller: _controller,
            onSend: () {
              vm.send(_controller.text);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final Message message;

  bool get _isTrainer => message.senderId == 'trainer-aarav-001';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: _isTrainer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _isTrainer ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: _isTrainer ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
            if (_isTrainer) ...[
              const SizedBox(width: 4),
              _StatusTick(status: message.status, color: scheme.onPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusTick extends StatelessWidget {
  const _StatusTick({required this.status, required this.color});
  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) => Icon(
        status == MessageStatus.read
            ? Icons.done_all_rounded
            : Icons.done_rounded,
        size: 14,
        color: color.withValues(alpha: 0.7),
      );
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Message DK…',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send_rounded),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
