import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';

class AuthViewModel extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final repo = ref.read(authRepositoryProvider);
    final existing = await repo.getUser(SeedUsers.trainer.id);
    if (existing != null) return existing;
    await repo.saveUser(SeedUsers.trainer);
    return SeedUsers.trainer;
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, User>(
  AuthViewModel.new,
);
