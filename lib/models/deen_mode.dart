import 'package:hive/hive.dart';

part 'deen_mode.g.dart';

/// Deen Mode purpose options
enum DeenModePurpose {
  quran,
  prayer,
  learning,
  reflect,
}

/// Deen Mode settings model
@HiveType(typeId: 15)
class DeenModeSettings {
  @HiveField(0)
  final bool isEnabled;

  @HiveField(1)
  final DateTime? startTime;

  @HiveField(2)
  final DateTime? endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String purpose; // quran, prayer, learning, reflect

  @HiveField(5)
  final bool notificationsMuted;

  DeenModeSettings({
    this.isEnabled = false,
    this.startTime,
    this.endTime,
    this.durationMinutes = 60,
    this.purpose = 'quran',
    this.notificationsMuted = true,
  });

  DeenModeSettings copyWith({
    bool? isEnabled,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? purpose,
    bool? notificationsMuted,
  }) {
    return DeenModeSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      purpose: purpose ?? this.purpose,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
    );
  }

  /// Get remaining time
  Duration get remainingTime {
    if (!isEnabled || startTime == null) return Duration.zero;
    final end = startTime!.add(Duration(minutes: durationMinutes));
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if session has expired
  bool get hasExpired {
    if (!isEnabled || startTime == null) return false;
    return remainingTime <= Duration.zero;
  }

  /// Get progress (0.0 to 1.0)
  double get progress {
    if (!isEnabled || startTime == null) return 0.0;
    final elapsed = DateTime.now().difference(startTime!);
    final total = Duration(minutes: durationMinutes);
    return (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }
}
