import 'package:hive/hive.dart';

part 'focus_mode.g.dart';

@HiveType(typeId: 7)
class FocusModeSettings {
  @HiveField(0)
  final bool isEnabled;

  @HiveField(1)
  final List<String> allowedApps; // Package names of apps allowed during focus

  @HiveField(2)
  final DateTime? startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final String? blockMessage; // Custom message shown when blocking apps

  FocusModeSettings({
    this.isEnabled = false,
    List<String>? allowedApps,
    this.startTime,
    this.endTime,
    this.blockMessage,
  }) : allowedApps = allowedApps ?? [];

  FocusModeSettings copyWith({
    bool? isEnabled,
    List<String>? allowedApps,
    DateTime? startTime,
    DateTime? endTime,
    String? blockMessage,
  }) {
    return FocusModeSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      allowedApps: allowedApps ?? this.allowedApps,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      blockMessage: blockMessage ?? this.blockMessage,
    );
  }

  bool isAppAllowed(String packageName) {
    return allowedApps.contains(packageName);
  }

  bool canAddMoreApps() {
    return allowedApps.length < 5;
  }

  int get remainingSlots => 5 - allowedApps.length;
}
