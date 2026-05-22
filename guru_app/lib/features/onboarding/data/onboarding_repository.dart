abstract interface class OnboardingRepository {
  bool isDone();
  Future<void> setDone();
}
