import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class RequestsViewModel extends AsyncNotifier<List<CallRequest>> {
  static const _chatId = 'chat-dk-aarav';

  @override
  Future<List<CallRequest>> build() async =>
      ref.read(callRequestRepositoryProvider).getAll();

  Future<void> approve(String requestId) async {
    final repo = ref.read(callRequestRepositoryProvider);
    await repo.updateStatus(requestId, CallRequestStatus.approved);

    // Post a system message in the shared chat
    final systemMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatId,
      senderId: 'system',
      receiverId: 'member-dk-001',
      text: '✅ Your call request has been approved by Aarav!',
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    await ref.read(chatRepositoryProvider).saveMessage(systemMsg);

    await _reload();
  }

  Future<void> decline(String requestId) async {
    await ref
        .read(callRequestRepositoryProvider)
        .updateStatus(requestId, CallRequestStatus.declined);
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
