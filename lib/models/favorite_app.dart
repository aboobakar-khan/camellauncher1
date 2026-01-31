import 'package:hive/hive.dart';

part 'favorite_app.g.dart';

@HiveType(typeId: 8)
class FavoriteApp {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final DateTime addedAt;

  FavoriteApp({
    required this.packageName,
    required this.appName,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  FavoriteApp copyWith({
    String? packageName,
    String? appName,
    DateTime? addedAt,
  }) {
    return FavoriteApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
