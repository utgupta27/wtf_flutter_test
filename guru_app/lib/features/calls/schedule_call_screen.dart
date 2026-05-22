import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';
import 'package:guru_app/features/calls/viewmodel/schedule_call_viewmodel.dart';
import 'package:shared/constants/ui_copy.dart';

class ScheduleCallScreen extends ConsumerWidget {
  const ScheduleCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCallViewModelProvider);
    final vm = ref.read(scheduleCallViewModelProvider.notifier);

    if (state.submitted) {
      return _SuccessView(
        onDone: () => context.go('/home'),
        onViewRequests: () => context.push('/requests'),
      );
    }

    return GuruSubpageScaffold(
      title: const Text('Schedule a Call'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pick a day',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _DaySelector(
              selectedDate: state.selectedDate,
              onSelect: vm.selectDate,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pick a time',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _SlotGrid(
              selectedDate: state.selectedDate,
              selectedSlot: state.selectedSlot,
              onSelect: vm.selectSlot,
            ),
            const SizedBox(height: 24),
            const Text(
              'Add a note (optional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLength: 140,
              maxLines: 3,
              onChanged: vm.updateNote,
              decoration: const InputDecoration(
                hintText: 'E.g. Focus on upper body today...',
                border: OutlineInputBorder(),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        await vm.submit();
                        if (context.mounted &&
                            ref.read(scheduleCallViewModelProvider).submitted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(UiCopy.callRequestedWaiting),
                            ),
                          );
                        }
                      },
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Request Call'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDate, required this.onSelect});
  final DateTime selectedDate;
  final void Function(DateTime) onSelect;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = [
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
    ];

    return Row(
      children: days.map((day) {
        final isSelected = _isSameDay(day, selectedDate);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(DateFormat('EEE d').format(day)),
            selected: isSelected,
            onSelected: (_) => onSelect(day),
          ),
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.selectedDate,
    required this.selectedSlot,
    required this.onSelect,
  });
  final DateTime selectedDate;
  final DateTime? selectedSlot;
  final void Function(DateTime) onSelect;

  static final _slots = List.generate(24, (i) {
    final hour = 8 + i ~/ 2;
    final minute = (i % 2) * 30;
    return (hour: hour, minute: minute);
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slots.map((s) {
        final slotTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          s.hour,
          s.minute,
        );

        // Hide slots that are in the past for the selected day.
        if (slotTime.isBefore(now)) return const SizedBox.shrink();

        final isSelected = selectedSlot != null &&
            selectedSlot!.year == slotTime.year &&
            selectedSlot!.month == slotTime.month &&
            selectedSlot!.day == slotTime.day &&
            selectedSlot!.hour == slotTime.hour &&
            selectedSlot!.minute == slotTime.minute;

        final label = DateFormat('h:mm a').format(slotTime);

        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: (_) => onSelect(slotTime),
        );
      }).toList(),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.onDone,
    required this.onViewRequests,
  });
  final VoidCallback onDone;
  final VoidCallback onViewRequests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Request Sent!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                UiCopy.callRequestedWaiting,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onViewRequests,
                child: const Text('View My Requests'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onDone, child: const Text('Back to Home')),
            ],
          ),
        ),
      ),
    );
  }
}
