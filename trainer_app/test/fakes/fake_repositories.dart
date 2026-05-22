import 'package:shared/shared.dart';

import 'package:trainer_app/features/auth/data/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({User? user}) : _user = user ?? SeedUsers.trainer;
  User _user;

  @override
  Future<User?> getUser(String id) async => _user.id == id ? _user : null;

  @override
  Future<void> saveUser(User user) async => _user = user;
}
