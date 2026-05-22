import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';
import 'package:trainer_app/providers/sync_provider.dart';

class RequestsViewModel extends AsyncNotifier<List<CallRequest>> {
  static const _chatId = SyncConstants.defaultChatId;

  @override
  Future<List<CallRequest>> build() async {
    ref.listen(syncTickProvider, (prev, next) {
      ref.invalidateSelf();
    });
    return ref.read(callRequestRepositoryProvider).getAll();
  }

  Future<void> approve(String requestId) async {
    final repo = ref.read(callRequestRepositoryProvider);
    final all = await repo.getAll();
    CallRequest? request;
    for (final r in all) {
      if (r.id == requestId) {
        request = r;
        break;
      }
    }
    if (request == null) return;

    await repo.updateStatus(requestId, CallRequestStatus.approved);
    ref.read(syncServiceProvider).enqueueCallRequestPatch(
          requestId,
          CallRequestStatus.approved,
        );

    final timeLabel = DateFormat('h:mm a').format(request.scheduledFor);
    final systemMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatId,
      senderId: 'system',
      receiverId: SyncConstants.memberId,
      text: 'Call approved for $timeLabel',
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    await ref.read(chatRepositoryProvider).saveMessage(systemMsg);
    ref.read(syncServiceProvider).enqueueMessage(systemMsg);

    await _reload();
  }

  Future<void> decline(String requestId, {required String reason}) async {
    await ref
        .read(callRequestRepositoryProvider)
        .updateStatus(requestId, CallRequestStatus.declined);
    ref.read(syncServiceProvider).enqueueCallRequestPatch(
          requestId,
          CallRequestStatus.declined,
          declineReason: reason,
        );

    final systemMsg = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}-decline',
      chatId: _chatId,
      senderId: 'system',
      receiverId: SyncConstants.memberId,
      text: 'Call declined: $reason',
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    await ref.read(chatRepositoryProvider).saveMessage(systemMsg);
    ref.read(syncServiceProvider).enqueueMessage(systemMsg);

    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(callRequestRepositoryProvider).getAll(),
    );
  }
}

final requestsViewModelProvider =
    AsyncNotifierProvider<RequestsViewModel, List<CallRequest>>(
  RequestsViewModel.new,
);
