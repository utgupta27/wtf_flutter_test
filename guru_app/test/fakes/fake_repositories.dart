import 'package:shared/shared.dart';

import 'package:guru_app/features/auth/data/auth_repository.dart';
import 'package:guru_app/features/chat/data/chat_repository.dart';
import 'package:guru_app/features/onboarding/data/onboarding_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({User? user}) : _user = user ?? SeedUsers.member;
  User _user;

  @override
  Future<User?> getUser(String id) async => _user.id == id ? _user : null;

  @override
  Future<void> saveUser(User user) async => _user = user;
}

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({bool done = false}) : _done = done;
  bool _done;

  @override
  bool isDone() => _done;

  @override
  Future<void> setDone() async => _done = true;
}

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({List<Message>? messages})
      : _messages = messages ?? [];
  final List<Message> _messages;

  @override
  Future<List<Message>> getMessages(String chatId) async =>
      _messages.where((m) => m.chatId == chatId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<void> saveMessage(Message message) async => _messages.add(message);

  @override
  Future<void> updateStatus(String messageId, MessageStatus status) async {
    final i = _messages.indexWhere((m) => m.id == messageId);
    if (i != -1) {
      _messages[i] = _messages[i].copyWith(status: status);
    }
  }
}
