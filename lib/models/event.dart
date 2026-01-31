import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 11)
class Event {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime eventDate;

  @HiveField(4)
  DateTime? eventEndDate;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isAllDay;

  @HiveField(7)
  int? reminderMinutes; // Minutes before event to remind

  @HiveField(8)
  String? color; // Hex color code for event

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventEndDate,
    required this.createdAt,
    this.isAllDay = true,
    this.reminderMinutes,
    this.color,
  });

  /// Check if event is on a specific date
  bool isOnDate(DateTime date) {
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final checkDay = DateTime(date.year, date.month, date.day);

    if (eventEndDate != null) {
      final endDay = DateTime(
        eventEndDate!.year,
        eventEndDate!.month,
        eventEndDate!.day,
      );
      return !checkDay.isBefore(eventDay) && !checkDay.isAfter(endDay);
    }

    return eventDay == checkDay;
  }

  /// Check if event is upcoming (today or future)
  bool get isUpcoming {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return !eventDay.isBefore(todayDate);
  }

  /// Get days until event
  int get daysUntil {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return eventDay.difference(todayDate).inDays;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? eventEndDate,
    DateTime? createdAt,
    bool? isAllDay,
    int? reminderMinutes,
    String? color,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      createdAt: createdAt ?? this.createdAt,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      color: color ?? this.color,
    );
  }
}
