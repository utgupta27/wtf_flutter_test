import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:guru_app/providers/repository_providers.dart';

/// Exposes whether onboarding has been completed.
final onboardingViewModelProvider = NotifierProvider<OnboardingViewModel, bool>(
  OnboardingViewModel.new,
);

class OnboardingViewModel extends Notifier<bool> {
  @override
  bool build() => ref.read(onboardingRepositoryProvider).isDone();

  /// Saves DK profile with chosen trainer, then marks onboarding complete.
  Future<void> completeProfile({
    required String name,
    required String trainerId,
  }) async {
    final trimmedName = name.trim();
    final profile = User(
      id: SeedUsers.member.id,
      name: trimmedName.isEmpty ? 'DK' : trimmedName,
      email: SeedUsers.member.email,
      role: 'member',
      assignedTrainerId: trainerId,
    );
    await ref.read(authRepositoryProvider).saveUser(profile);
    await ref.read(onboardingRepositoryProvider).setDone();
    state = true;
    ref.invalidate(authViewModelProvider);
  }
}
