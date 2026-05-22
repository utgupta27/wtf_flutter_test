import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    return _loadOrSeedUser();
  }

  Future<User> _loadOrSeedUser() async {
    const boxName = AppConstants.hiveBoxUsers;
    final box = await Hive.openBox<Map>(boxName);
    final raw = box.get(SeedUsers.member.id);
    if (raw != null) {
      return User.fromMap(Map<String, dynamic>.from(raw));
    }
    // First launch — seed DK's profile
    const user = SeedUsers.member;
    await box.put(user.id, user.toMap());
    return user;
  }
}
