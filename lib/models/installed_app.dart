import 'package:hive/hive.dart';

part 'installed_app.g.dart';

/// Minimalist app data stored in Hive
/// Text-only, no icons - instant performance
@HiveType(typeId: 9)
class InstalledApp {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final DateTime lastUpdated;

  InstalledApp({
    required this.packageName,
    required this.appName,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  InstalledApp copyWith({
    String? packageName,
    String? appName,
    DateTime? lastUpdated,
  }) {
    return InstalledApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
