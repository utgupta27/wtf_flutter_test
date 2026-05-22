import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/auth/data/auth_repository.dart';
import 'package:trainer_app/features/auth/data/auth_repository_impl.dart';
import 'package:shared/shared.dart';
import 'package:trainer_app/features/calls/service/hms_video_call_service.dart';
import 'package:trainer_app/features/calls/service/video_call_service.dart';
import 'package:trainer_app/features/requests/data/call_request_repository.dart';
import 'package:trainer_app/features/requests/data/call_request_repository_impl.dart';
import 'package:trainer_app/features/sessions/data/session_log_repository.dart';
import 'package:trainer_app/features/sessions/data/session_log_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HiveAuthRepository(Hive.box(AppConstants.hiveBoxUsers)),
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
