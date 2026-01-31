import 'package:hive/hive.dart';

part 'hidden_app.g.dart';

@HiveType(typeId: 10) // Next available typeId after InstalledApp (9)
class HiddenApp extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final bool isHiddenByUser; // true = user hid it, false = system filtered it

  @HiveField(3)
  final DateTime lastModified;

  HiddenApp({
    required this.packageName,
    required this.appName,
    required this.isHiddenByUser,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  /// Create a copy with updated fields
  HiddenApp copyWith({
    String? packageName,
    String? appName,
    bool? isHiddenByUser,
    DateTime? lastModified,
  }) {
    return HiddenApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isHiddenByUser: isHiddenByUser ?? this.isHiddenByUser,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
