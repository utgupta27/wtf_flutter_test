import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guru_app/providers/repository_providers.dart';

/// Exposes whether onboarding has been completed.
/// Screens listen to this to trigger navigation side-effects.
final onboardingViewModelProvider = NotifierProvider<OnboardingViewModel, bool>(
  OnboardingViewModel.new,
);

class OnboardingViewModel extends Notifier<bool> {
  @override
  bool build() => ref.read(onboardingRepositoryProvider).isDone();

  Future<void> complete() async {
    await ref.read(onboardingRepositoryProvider).setDone();
    state = true;
  }
}
