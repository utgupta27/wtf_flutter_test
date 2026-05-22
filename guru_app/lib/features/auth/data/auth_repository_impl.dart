import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/features/auth/data/auth_repository.dart';

class HiveAuthRepository implements AuthRepository {
  const HiveAuthRepository(this._box);
  final Box<dynamic> _box;

  @override
  Future<User?> getUser(String id) async {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    return User.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<void> saveUser(User user) async {
    await _box.put(user.id, user.toMap());
  }
}
