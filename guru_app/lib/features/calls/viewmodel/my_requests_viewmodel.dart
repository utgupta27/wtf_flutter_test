import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';

final myRequestsViewModelProvider =
    AsyncNotifierProvider<MyRequestsViewModel, List<CallRequest>>(
  MyRequestsViewModel.new,
);

class MyRequestsViewModel extends AsyncNotifier<List<CallRequest>> {
  @override
  Future<List<CallRequest>> build() async {
    ref.listen(syncTickProvider, (prev, next) {
      ref.invalidateSelf();
    });
    final all = await ref.read(callRequestRepositoryProvider).getAll();
    all.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return all;
  }
}
