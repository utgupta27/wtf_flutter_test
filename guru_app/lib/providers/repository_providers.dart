import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/auth/data/auth_repository.dart';
import 'package:guru_app/features/auth/data/auth_repository_impl.dart';
import 'package:guru_app/features/chat/data/chat_repository.dart';
import 'package:guru_app/features/chat/data/chat_repository_impl.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HiveAuthRepository(Hive.box(AppConstants.hiveBoxUsers)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => HiveOnboardingRepository(Hive.box(AppConstants.hiveBoxSettings)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => HiveChatRepository(Hive.box(AppConstants.hiveBoxMessages)),
);
