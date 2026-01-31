import 'package:hive/hive.dart';

part 'app_interrupt.g.dart';

@HiveType(typeId: 5)
class AppInterrupt {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final InterruptMethod method;

  @HiveField(3)
  final String? customPassword; // For text input method

  @HiveField(4)
  final String? reminderMessage; // Why user set the interrupt

  @HiveField(5)
  final bool showReminder; // Whether to show reminder dialog

  @HiveField(6)
  final bool isEnabled;

  @HiveField(7)
  final DateTime createdAt;

  AppInterrupt({
    required this.packageName,
    required this.appName,
    required this.method,
    this.customPassword,
    this.reminderMessage,
    this.showReminder = true,
    this.isEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AppInterrupt copyWith({
    String? packageName,
    String? appName,
    InterruptMethod? method,
    String? customPassword,
    String? reminderMessage,
    bool? showReminder,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return AppInterrupt(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      method: method ?? this.method,
      customPassword: customPassword ?? this.customPassword,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      showReminder: showReminder ?? this.showReminder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 6)
enum InterruptMethod {
  @HiveField(0)
  timer30, // 30-second wait timer

  @HiveField(1)
  textPassword, // Require text input (password)

  @HiveField(2)
  voiceConfirmation, // Voice confirmation

  @HiveField(3)
  timerAndReminder, // Timer + reminder dialog

  @HiveField(4)
  passwordAndReminder, // Password + reminder dialog

  @HiveField(5)
  voiceAndReminder, // Voice + reminder dialog
}

extension InterruptMethodExtension on InterruptMethod {
  String get displayName {
    switch (this) {
      case InterruptMethod.timer30:
        return '30-Second Timer';
      case InterruptMethod.textPassword:
        return 'Password Input';
      case InterruptMethod.voiceConfirmation:
        return 'Voice Confirmation';
      case InterruptMethod.timerAndReminder:
        return 'Timer + Reminder';
      case InterruptMethod.passwordAndReminder:
        return 'Password + Reminder';
      case InterruptMethod.voiceAndReminder:
        return 'Voice + Reminder';
    }
  }

  String get description {
    switch (this) {
      case InterruptMethod.timer30:
        return 'Wait 30 seconds before opening';
      case InterruptMethod.textPassword:
        return 'Enter password to open';
      case InterruptMethod.voiceConfirmation:
        return 'Say the app name to open';
      case InterruptMethod.timerAndReminder:
        return 'Timer with reminder message';
      case InterruptMethod.passwordAndReminder:
        return 'Password with reminder message';
      case InterruptMethod.voiceAndReminder:
        return 'Voice with reminder message';
    }
  }

  bool get requiresPassword {
    return this == InterruptMethod.textPassword ||
        this == InterruptMethod.passwordAndReminder;
  }

  bool get requiresReminder {
    return this == InterruptMethod.timerAndReminder ||
        this == InterruptMethod.passwordAndReminder ||
        this == InterruptMethod.voiceAndReminder;
  }

  bool get usesVoice {
    return this == InterruptMethod.voiceConfirmation ||
        this == InterruptMethod.voiceAndReminder;
  }

  bool get usesTimer {
    return this == InterruptMethod.timer30 ||
        this == InterruptMethod.timerAndReminder;
  }
}
