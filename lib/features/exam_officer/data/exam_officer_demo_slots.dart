import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class ExamOfficerDemoSlots {
  ExamOfficerDemoSlots._();

  static bool _seeded = false;

  static void ensure() {
    if (_seeded) return;
    _seeded = true;

    final calendar = CbtCalendarState.instance;
    final desired = <({
      DateTime date,
      String start,
      String end,
      String venue,
      int capacity,
    })>[
      (
        date: DateTime(2026, 9, 25),
        start: '13:00',
        end: '15:00',
        venue: 'CBT Centre A',
        capacity: 250,
      ),
      (
        date: DateTime(2026, 9, 26),
        start: '09:00',
        end: '11:00',
        venue: 'CBT Centre A',
        capacity: 250,
      ),
      (
        date: DateTime(2026, 9, 26),
        start: '13:00',
        end: '15:00',
        venue: 'CBT Centre B',
        capacity: 180,
      ),
      (
        date: DateTime(2026, 9, 27),
        start: '09:00',
        end: '12:00',
        venue: 'CBT Centre Main',
        capacity: 300,
      ),
      (
        date: DateTime(2026, 9, 28),
        start: '09:00',
        end: '11:00',
        venue: 'CBT Centre C',
        capacity: 160,
      ),
      (
        date: DateTime(2026, 9, 28),
        start: '13:00',
        end: '16:00',
        venue: 'CBT Centre Main',
        capacity: 300,
      ),
    ];

    for (final item in desired) {
      final exists = calendar.slots.any(
        (slot) =>
            slot.date.year == item.date.year &&
            slot.date.month == item.date.month &&
            slot.date.day == item.date.day &&
            slot.startTime == item.start &&
            slot.endTime == item.end &&
            slot.venue == item.venue,
      );
      if (exists) continue;
      calendar.addSlot(
        date: item.date,
        startTime: item.start,
        endTime: item.end,
        venue: item.venue,
        capacity: item.capacity,
      );
    }
  }
}
