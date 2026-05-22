import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/auth/data/auth_repository.dart';
import 'package:trainer_app/features/auth/data/auth_repository_impl.dart';
import 'package:trainer_app/features/chat/data/chat_repository.dart';
import 'package:trainer_app/features/chat/data/chat_repository_impl.dart';
import 'package:trainer_app/features/requests/data/call_request_repository.dart';
import 'package:trainer_app/features/requests/data/call_request_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HiveAuthRepository(Hive.box(AppConstants.hiveBoxUsers)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => HiveChatRepository(Hive.box(AppConstants.hiveBoxMessages)),
);

final callRequestRepositoryProvider = Provider<CallRequestRepository>(
  (ref) => HiveCallRequestRepository(Hive.box(AppConstants.hiveBoxCallRequests)),
);
