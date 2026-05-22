import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class HomeViewModel extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getUser(SeedUsers.trainer.id);
    return user ?? SeedUsers.trainer;
  }
}

final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, User>(
  HomeViewModel.new,
);
