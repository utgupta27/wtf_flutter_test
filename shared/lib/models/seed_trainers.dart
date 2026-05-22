import 'package:shared/models/user.dart';

/// Trainers available for member assignment during guru onboarding.
abstract class SeedTrainers {
  static const List<User> list = [
    SeedUsers.trainer,
    User(
      id: 'trainer-priya-001',
      name: 'Priya',
      email: 'priya@wtf.com',
      role: 'trainer',
    ),
    User(
      id: 'trainer-mike-001',
      name: 'Mike',
      email: 'mike@wtf.com',
      role: 'trainer',
    ),
  ];
}
