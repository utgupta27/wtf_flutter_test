import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, User>(
  AuthViewModel.new,
);

class AuthViewModel extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final repo = ref.read(authRepositoryProvider);
    final existing = await repo.getUser(SeedUsers.member.id);
    if (existing != null) {
      return existing;
    }
    const user = SeedUsers.member;
    await repo.saveUser(user);
    return user;
  }
}
