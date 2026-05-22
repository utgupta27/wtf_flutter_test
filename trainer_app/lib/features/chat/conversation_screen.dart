import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/chat/providers/joinable_call_provider.dart';

/// Trainer shell around shared [ConversationPage].
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key, required this.chatId});

  final String chatId;

  static final _config = ChatAppConfig.trainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinable = ref.watch(joinableCallRequestProvider).valueOrNull;

    return ConversationPage(
      chatId: chatId,
      config: _config,
      appBarActions: joinable != null
          ? [
              IconButton(
                tooltip: 'Join call',
                onPressed: () => context.push('/call/${joinable.id}'),
                icon: const Badge(
                  label: Text('1'),
                  child: Icon(Icons.videocam_rounded),
                ),
              ),
            ]
          : null,
      scaffoldBuilder: ({
        required Widget title,
        required List<Widget>? actions,
        required Widget body,
      }) =>
          Scaffold(
        appBar: AppBar(title: title, actions: actions),
        body: body,
      ),
    );
  }
}
