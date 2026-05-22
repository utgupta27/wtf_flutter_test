import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/providers/repository_providers.dart';

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

  void updateNote(String note) =>
      state = state.copyWith(note: note, error: null);

  Future<void> submit() async {
    if (state.selectedSlot == null) {
      state = state.copyWith(error: 'Please select a time slot');
      return;
    }
    state = state.copyWith(isSubmitting: true, error: null);

    final repo = ref.read(callRequestRepositoryProvider);  // from repository_providers
    const trainerId = 'trainer-aarav-001';

    final conflict = await repo.hasConflict(state.selectedSlot!, trainerId);
    if (conflict) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'This slot is already booked. Please choose another time.',
      );
      return;
    }

    final request = CallRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: 'member-dk-001',
      trainerId: trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: state.selectedSlot!,
      note: state.note.trim(),
    );

    await repo.save(request);
    state = state.copyWith(isSubmitting: false, submitted: true);
  }
}

final scheduleCallViewModelProvider =
    NotifierProvider<ScheduleCallViewModel, ScheduleCallState>(
  ScheduleCallViewModel.new,
);

