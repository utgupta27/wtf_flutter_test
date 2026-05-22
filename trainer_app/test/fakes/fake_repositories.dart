import 'package:shared/shared.dart';

import 'package:trainer_app/features/auth/data/auth_repository.dart';
import 'package:trainer_app/features/chat/data/chat_repository.dart';
import 'package:trainer_app/features/requests/data/call_request_repository.dart';

class FakeCallRequestRepository implements CallRequestRepository {
  FakeCallRequestRepository({List<CallRequest>? requests})
      : _requests = requests ?? [];
  final List<CallRequest> _requests;

  @override
  Future<List<CallRequest>> getAll() async => List.from(_requests);

  @override
  Future<void> updateStatus(String id, CallRequestStatus status) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i != -1) _requests[i] = _requests[i].copyWith(status: status);
  }
}

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({List<Message>? messages}) : _messages = messages ?? [];
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
    if (i != -1) _messages[i] = _messages[i].copyWith(status: status);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({User? user}) : _user = user ?? SeedUsers.trainer;
  User _user;

  @override
  Future<User?> getUser(String id) async => _user.id == id ? _user : null;

  @override
  Future<void> saveUser(User user) async => _user = user;
}
