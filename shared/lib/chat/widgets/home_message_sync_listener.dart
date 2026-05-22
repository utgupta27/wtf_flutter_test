import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/config/chat_app_config.dart';
import 'package:shared/chat/state/chat_list_viewmodel.dart';
import 'package:shared/chat/state/chat_providers.dart';
import 'package:shared/sync/message_sync_service.dart';

/// Wraps home content: pulls messages on mount and refreshes UI on sync ticks.
class HomeMessageSyncListener extends ConsumerStatefulWidget {
  const HomeMessageSyncListener({
    super.key,
    required this.config,
    required this.child,
  });

  final ChatAppConfig config;
  final Widget child;

  @override
  ConsumerState<HomeMessageSyncListener> createState() =>
      _HomeMessageSyncListenerState();
}

class _HomeMessageSyncListenerState extends ConsumerState<HomeMessageSyncListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMessages());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncMessages();
    }
  }

  void _syncMessages() {
    ref.read(messageSyncServiceProvider).syncNow();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sharedSyncTickProvider, (previous, next) {
      ref.invalidate(chatListViewModelProvider(widget.config));
    });

    return widget.child;
  }
}

/// Riverpod accessor for [MessageSyncService].
final messageSyncServiceProvider = Provider<MessageSyncService>((ref) {
  return MessageSyncService(ref.watch(sharedSyncServiceProvider));
});
