import 'package:shared/shared.dart';

import 'package:guru_app/features/auth/data/auth_repository.dart';
import 'package:guru_app/features/calls/data/call_request_repository.dart';
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

class FakeCallRequestRepository implements CallRequestRepository {
  FakeCallRequestRepository({List<CallRequest>? requests, bool conflictResult = false})
      : _requests = requests ?? [],
        _conflictResult = conflictResult;

  final List<CallRequest> _requests;
  final bool _conflictResult;

  @override
  Future<List<CallRequest>> getAll() async => List.from(_requests);

  @override
  Future<CallRequest?> getById(String id) async =>
      _requests.cast<CallRequest?>().firstWhere(
            (r) => r?.id == id,
            orElse: () => null,
          );

  @override
  Future<void> save(CallRequest request) async => _requests.add(request);

  @override
  Future<void> updateStatus(String id, CallRequestStatus status) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i != -1) {
      _requests[i] = _requests[i].copyWith(status: status);
    }
  }

  @override
  Future<bool> hasConflict(DateTime scheduledFor, String trainerId) async =>
      _conflictResult;
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
