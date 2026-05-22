import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';

class ScheduleCallState {
  const ScheduleCallState({
    required this.selectedDate,
    this.selectedSlot,
    this.note = '',
    this.isSubmitting = false,
    this.submitted = false,
    this.error,
  });

  final DateTime selectedDate;
  final DateTime? selectedSlot;
  final String note;
  final bool isSubmitting;
  final bool submitted;
  final String? error;

  ScheduleCallState copyWith({
    DateTime? selectedDate,
    Object? selectedSlot = _sentinel,
    String? note,
    bool? isSubmitting,
    bool? submitted,
    Object? error = _sentinel,
  }) =>
      ScheduleCallState(
        selectedDate: selectedDate ?? this.selectedDate,
        selectedSlot:
            selectedSlot == _sentinel ? this.selectedSlot : selectedSlot as DateTime?,
        note: note ?? this.note,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitted: submitted ?? this.submitted,
        error: error == _sentinel ? this.error : error as String?,
      );
}

const _sentinel = Object();

class ScheduleCallViewModel extends Notifier<ScheduleCallState> {
  static const _chatId = SyncConstants.defaultChatId;

  @override
  ScheduleCallState build() => ScheduleCallState(
        selectedDate: DateTime.now(),
      );

  void selectDate(DateTime date) => state = state.copyWith(
        selectedDate: date,
        selectedSlot: null,
        error: null,
      );

  void selectSlot(DateTime slot) =>
      state = state.copyWith(selectedSlot: slot, error: null);

  /// Sets date and time to [now + 1 minute] for quick test scheduling.
  void pickOneMinuteFromNow() {
    final slot = DateTime.now().add(const Duration(minutes: 1));
    state = state.copyWith(
      selectedDate: DateTime(slot.year, slot.month, slot.day),
      selectedSlot: slot,
      error: null,
    );
  }

  /// Schedules a call one minute from now (same validation as [submit]).
  Future<void> scheduleInOneMinute() async {
    pickOneMinuteFromNow();
    await submit();
  }

  void updateNote(String note) =>
      state = state.copyWith(note: note, error: null);

  Future<void> submit() async {
    final slot = state.selectedSlot;
    if (slot == null) {
      state = state.copyWith(error: 'Please select a time slot');
      return;
    }
    if (!slot.isAfter(DateTime.now())) {
      state = state.copyWith(error: 'Cannot schedule a time in the past');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    final repo = ref.read(callRequestRepositoryProvider);
    const trainerId = SyncConstants.trainerId;

    final conflict = await repo.hasConflict(slot, trainerId);
    if (conflict) {
      AppLog.w(LogTag.schedule, 'schedule conflict', detail: 'slot=$slot');
      state = state.copyWith(
        isSubmitting: false,
        error: 'This slot is already booked. Please choose another time.',
      );
      return;
    }

    final request = CallRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: SyncConstants.memberId,
      trainerId: trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: slot,
      note: state.note.trim(),
    );

    await repo.save(request);
    ref.read(syncServiceProvider).enqueueCallRequest(request);

    final systemMsg = Message(
      id: '${request.id}-requested',
      chatId: _chatId,
      senderId: 'system',
      receiverId: SyncConstants.trainerId,
      text: UiCopy.callRequestedWaiting,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    await ref.read(chatRepositoryProvider).saveMessage(systemMsg);
    ref.read(syncServiceProvider).enqueueMessage(systemMsg);
    AppLog.i(
      LogTag.schedule,
      'call request created',
      detail: 'id=${request.id} scheduledFor=$slot',
    );

    state = state.copyWith(isSubmitting: false, submitted: true);
  }
}

final scheduleCallViewModelProvider =
    NotifierProvider<ScheduleCallViewModel, ScheduleCallState>(
  ScheduleCallViewModel.new,
);
