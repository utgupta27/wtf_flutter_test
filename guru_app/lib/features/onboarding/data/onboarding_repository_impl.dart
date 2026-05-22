import 'package:hive_flutter/hive_flutter.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository.dart';

class HiveOnboardingRepository implements OnboardingRepository {
  const HiveOnboardingRepository(this._box);
  final Box<dynamic> _box;

  @override
  bool isDone() =>
      _box.get(AppConstants.settingsKeyOnboardingDone, defaultValue: false) as bool;

  @override
  Future<void> setDone() =>
      _box.put(AppConstants.settingsKeyOnboardingDone, true);
}
