import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';

const _uuid = Uuid();

/// Provider for the list of events
final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>(
  (ref) {
    return EventListNotifier();
  },
);

/// Provider to get events for a specific date
final eventsForDateProvider = Provider.family<List<Event>, DateTime>((
  ref,
  date,
) {
  final events = ref.watch(eventListProvider);
  return events.where((e) => e.isOnDate(date)).toList();
});

/// Provider to get upcoming events (sorted by date)
final upcomingEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventListProvider);
  final upcoming = events.where((e) => e.isUpcoming).toList();
  upcoming.sort((a, b) => a.eventDate.compareTo(b.eventDate));
  return upcoming;
});

/// Provider to get all dates that have events (for calendar markers)
final eventDatesProvider = Provider<Set<DateTime>>((ref) {
  final events = ref.watch(eventListProvider);
  final dates = <DateTime>{};

  for (final event in events) {
    // Add the start date
    dates.add(
      DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      ),
    );

    // If multi-day event, add all dates in range
    if (event.eventEndDate != null) {
      var current = event.eventDate;
      while (!current.isAfter(event.eventEndDate!)) {
        dates.add(DateTime(current.year, current.month, current.day));
        current = current.add(const Duration(days: 1));
      }
    }
  }

  return dates;
});

class EventListNotifier extends StateNotifier<List<Event>> {
  Box<Event>? _box;

  EventListNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Event>('events');
      state = _box!.values.toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> addEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    DateTime? eventEndDate,
    bool isAllDay = true,
    int? reminderMinutes,
    String? color,
  }) async {
    _box ??= await Hive.openBox<Event>('events');

    final event = Event(
      id: _uuid.v4(),
      title: title.trim(),
      description: description?.trim(),
      eventDate: eventDate,
      eventEndDate: eventEndDate,
      createdAt: DateTime.now(),
      isAllDay: isAllDay,
      reminderMinutes: reminderMinutes,
      color: color,
    );

    await _box!.put(event.id, event);
    state = [...state, event];
  }

  Future<void> updateEvent(
    String id, {
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? eventEndDate,
    bool? isAllDay,
    int? reminderMinutes,
    String? color,
  }) async {
    if (_box == null) return;

    final event = _box!.get(id);
    if (event != null) {
      final updated = event.copyWith(
        title: title,
        description: description,
        eventDate: eventDate,
        eventEndDate: eventEndDate,
        isAllDay: isAllDay,
        reminderMinutes: reminderMinutes,
        color: color,
      );
      await _box!.put(id, updated);
      state = _box!.values.toList();
    }
  }

  Future<void> deleteEvent(String id) async {
    if (_box == null) return;

    await _box!.delete(id);
    state = state.where((event) => event.id != id).toList();
  }

  List<Event> getEventsForDate(DateTime date) {
    return state.where((e) => e.isOnDate(date)).toList();
  }
}
