import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/config/chat_theme.dart';
import 'package:shared/chat/logic/quick_reply_suggestions.dart';
import 'package:shared/chat/state/conversation_state.dart';
import 'package:shared/chat/state/conversation_viewmodel.dart';
import 'package:shared/chat/widgets/chat_bubble.dart';
import 'package:shared/chat/widgets/chat_input_bar.dart';
import 'package:shared/chat/widgets/quick_reply_bar.dart';
import 'package:shared/chat/widgets/home_message_sync_listener.dart';
import 'package:shared/chat/widgets/typing_indicator.dart';

/// Shared conversation UI; app wraps with scaffold and optional actions.
class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({
    super.key,
    required this.chatId,
    required this.config,
    required this.scaffoldBuilder,
    this.appBarActions,
  });

  final String chatId;
  final ChatAppConfig config;
  final List<Widget>? appBarActions;
  final Widget Function({
    required Widget title,
    required List<Widget>? actions,
    required Widget body,
  }) scaffoldBuilder;

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  ConversationParams get _params =>
      ConversationParams(chatId: widget.chatId, config: widget.config);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    await ref
        .read(conversationViewModelProvider(_params).notifier)
        .sendImage(file.path);
    _inputController.clear();
    _scrollToBottom();
  }

  void _handleSend([String? text]) {
    final message = (text ?? _inputController.text).trim();
    if (message.isEmpty) {
      return;
    }
    ref.read(conversationViewModelProvider(_params).notifier).send(message);
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageSyncServiceProvider).syncNow();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationViewModelProvider(_params));
    final vm = ref.read(conversationViewModelProvider(_params).notifier);

    return state.when(
      loading: () => widget.scaffoldBuilder(
        title: const Text('Chat'),
        actions: widget.appBarActions,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => widget.scaffoldBuilder(
        title: const Text('Chat'),
        actions: widget.appBarActions,
        body: Center(child: Text('Error: $e')),
      ),
      data: (conversation) {
        ref.listen(conversationViewModelProvider(_params), (prev, next) {
          final prevData = prev?.valueOrNull;
          final nextData = next.valueOrNull;
          if (nextData != null &&
              (prevData == null ||
                  prevData.messages.length != nextData.messages.length ||
                  prevData.isPeerTyping != nextData.isPeerTyping)) {
            _scrollToBottom();
          }
        });

        return _ConversationContent(
          config: widget.config,
          conversation: conversation,
          scrollController: _scrollController,
          inputController: _inputController,
          appBarActions: widget.appBarActions,
          scaffoldBuilder: widget.scaffoldBuilder,
          onSend: _handleSend,
          onChanged: vm.onComposerChanged,
          onAttach: _pickImage,
          onLoadOlder: vm.loadOlderMessages,
        );
      },
    );
  }
}

class _ConversationContent extends StatelessWidget {
  const _ConversationContent({
    required this.config,
    required this.conversation,
    required this.scrollController,
    required this.inputController,
    required this.appBarActions,
    required this.scaffoldBuilder,
    required this.onSend,
    required this.onChanged,
    required this.onAttach,
    required this.onLoadOlder,
  });

  final ChatAppConfig config;
  final ConversationState conversation;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final List<Widget>? appBarActions;
  final Widget Function({
    required Widget title,
    required List<Widget>? actions,
    required Widget body,
  }) scaffoldBuilder;
  final void Function([String? text]) onSend;
  final void Function(String text) onChanged;
  final VoidCallback onAttach;
  final Future<void> Function() onLoadOlder;

  @override
  Widget build(BuildContext context) {
    final visible = conversation.visibleMessages;
    final quickReplies = suggestQuickReplies(
      conversation.messages,
      peerUserId: config.peerUserId,
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(config.peerDisplayName),
        if (conversation.isPeerTyping)
          const Text(
            'typing...',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
      ],
    );

    final body = Column(
      children: [
        if (conversation.hasOlderMessages)
          Material(
            color: ChatTheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                conversation.isLoadingHistory
                    ? 'Loading earlier messages…'
                    : 'Pull down to load earlier messages',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: ChatTheme.subtle),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh:
                conversation.hasOlderMessages ? onLoadOlder : () async {},
            child: ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: visible.length + (conversation.isPeerTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (conversation.isPeerTyping && index == visible.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: ChatTypingIndicator(),
                    ),
                  );
                }
                final message = visible[index];
                return ChatBubble(message: message, config: config);
              },
            ),
          ),
        ),
        ChatQuickReplyBar(
          suggestions: quickReplies,
          onTap: (text) => onSend(text),
        ),
        ChatInputBar(
          controller: inputController,
          config: config,
          onSend: () => onSend(),
          onChanged: onChanged,
          onAttach: onAttach,
        ),
      ],
    );

    return scaffoldBuilder(
      title: title,
      actions: appBarActions,
      body: body,
    );
  }
}
