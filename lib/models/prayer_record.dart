import 'package:hive/hive.dart';

part 'prayer_record.g.dart';

/// Model for tracking daily prayer completions
/// Stores which of the 5 daily prayers have been completed for a given date
@HiveType(typeId: 12)
class PrayerRecord {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date; // Date only (time set to midnight)

  @HiveField(2)
  bool fajr;

  @HiveField(3)
  bool dhuhr;

  @HiveField(4)
  bool asr;

  @HiveField(5)
  bool maghrib;

  @HiveField(6)
  bool isha;

  @HiveField(7)
  DateTime createdAt;

  PrayerRecord({
    required this.id,
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    required this.createdAt,
  });

  /// Get the number of completed prayers (0-5)
  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    return count;
  }

  /// Get date key for lookups (YYYY-MM-DD format)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create a date-only DateTime (strips time component)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  PrayerRecord copyWith({
    String? id,
    DateTime? date,
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    DateTime? createdAt,
  }) {
    return PrayerRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
