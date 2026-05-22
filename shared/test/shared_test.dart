import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('SeedUsers', () {
    test('member has correct id and role', () {
      expect(SeedUsers.member.id, 'member-dk-001');
      expect(SeedUsers.member.role, 'member');
      expect(SeedUsers.member.assignedTrainerId, 'trainer-aarav-001');
    });

    test('trainer has correct id and role', () {
      expect(SeedUsers.trainer.id, 'trainer-aarav-001');
      expect(SeedUsers.trainer.role, 'trainer');
      expect(SeedUsers.trainer.assignedTrainerId, isNull);
    });
  });

  group('SeedTrainers', () {
    test('lists seeded trainers including Aarav', () {
      expect(SeedTrainers.list.length, greaterThanOrEqualTo(3));
      expect(
        SeedTrainers.list.map((t) => t.id),
        contains('trainer-aarav-001'),
      );
    });
  });

  group('Message', () {
    test('default status is sending', () {
      final msg = Message(
        id: '1',
        chatId: 'chat-1',
        senderId: 'member-dk-001',
        receiverId: 'trainer-aarav-001',
        text: 'Hello',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(msg.status, MessageStatus.sending);
    });
  });

  group('CallRequest', () {
    test('default status is pending', () {
      final req = CallRequest(
        id: 'cr-1',
        memberId: 'member-dk-001',
        trainerId: 'trainer-aarav-001',
        requestedAt: DateTime(2026, 1, 1),
        scheduledFor: DateTime(2026, 1, 2),
        note: 'Test note',
      );
      expect(req.status, CallRequestStatus.pending);
    });
  });
}
