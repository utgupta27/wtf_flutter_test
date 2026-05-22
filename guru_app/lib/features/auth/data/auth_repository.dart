import 'package:shared/shared.dart';

abstract interface class AuthRepository {
  Future<User?> getUser(String id);
  Future<void> saveUser(User user);
}
