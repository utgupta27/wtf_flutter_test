import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/auth/data/auth_repository.dart';
import 'package:trainer_app/features/auth/data/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HiveAuthRepository(Hive.box(AppConstants.hiveBoxUsers)),
);
