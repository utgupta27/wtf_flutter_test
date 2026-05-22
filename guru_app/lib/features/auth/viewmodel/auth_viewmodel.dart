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
      AppLog.i(LogTag.auth, 'member session loaded', detail: 'id=${existing.id}');
      return existing;
    }
    AppLog.i(LogTag.auth, 'member placeholder until onboarding');
    // In-memory placeholder until onboarding persists the profile.
    return const User(
      id: 'member-dk-001',
      name: 'DK',
      email: 'dk@wtf.com',
      role: 'member',
    );
  }
}
