import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/features/auth/data/auth_repository.dart';

class HiveAuthRepository implements AuthRepository {
  HiveAuthRepository(this._box);
  final Box _box;

  @override
  Future<User?> getUser(String id) async => _box.get(id) as User?;

  @override
  Future<void> saveUser(User user) async => _box.put(user.id, user);
}
