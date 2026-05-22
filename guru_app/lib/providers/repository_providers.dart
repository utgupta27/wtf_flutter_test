import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/features/auth/data/auth_repository.dart';
import 'package:guru_app/features/auth/data/auth_repository_impl.dart';
import 'package:guru_app/features/calls/data/call_request_repository.dart';
import 'package:guru_app/features/calls/data/call_request_repository_impl.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/calls/service/hms_video_call_service.dart';
import 'package:guru_app/features/calls/service/video_call_service.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:guru_app/features/sessions/data/session_log_repository.dart';
import 'package:guru_app/features/sessions/data/session_log_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HiveAuthRepository(Hive.box(AppConstants.hiveBoxUsers)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => HiveOnboardingRepository(Hive.box(AppConstants.hiveBoxSettings)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => HiveChatRepository(Hive.box(AppConstants.hiveBoxMessages)),
);

final callRequestRepositoryProvider = Provider<CallRequestRepository>(
  (ref) => HiveCallRequestRepository(Hive.box(AppConstants.hiveBoxCallRequests)),
);

final sessionLogRepositoryProvider = Provider<SessionLogRepository>(
  (ref) => HiveSessionLogRepository(Hive.box(AppConstants.hiveBoxSessionLogs)),
);

final videoCallServiceProvider = Provider<VideoCallService>((ref) {
  final service = HmsVideoCallService();
  ref.onDispose(service.dispose);
  return service;
});
