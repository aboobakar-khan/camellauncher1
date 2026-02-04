import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// App Usage Statistics Provider
/// Fetches and processes device usage data for Screen Time Analytics

// Known Islamic apps to classify
const Set<String> islamicApps = {
  'com.quran.labs.androidquran',
  'com.greentech.quran',
  'com.muslim.prayertimes.azan',
  'com.hadithcollection',
  'com.muslimpro',
  'com.islamicfinder.athanpro',
  'com.bitsmedia.android.muslimpro',
  'org.quran.android',
  'com.quanticapps.quranandroid',
  'com.guidedways.iQuran',
  // Add your app's package name
};

const Set<String> socialApps = {
  'com.instagram.android',
  'com.twitter.android',
  'com.facebook.katana',
  'com.snapchat.android',
  'com.tiktok.android',
  'com.zhiliaoapp.musically',
  'com.pinterest',
  'com.linkedin.android',
  'com.reddit.frontpage',
};

const Set<String> entertainmentApps = {
  'com.google.android.youtube',
  'com.netflix.mediaclient',
  'com.spotify.music',
  'com.amazon.avod.thirdpartyclient',
  // Games typically have 'game' in package name
};

const Set<String> messagingApps = {
  'com.whatsapp',
  'org.telegram.messenger',
  'com.discord',
  'com.Slack',
  'com.google.android.apps.messaging',
};

const Set<String> productiveApps = {
  'com.google.android.calendar',
  'com.google.android.keep',
  'com.microsoft.office.outlook',
  'com.notion.id',
  'com.todoist',
  'com.google.android.apps.docs',
};

/// App category enum
enum AppCategory {
  islamic,
  productive,
  social,
  entertainment,
  messaging,
  utility,
}

/// Single app usage data
class AppUsageInfo {
  final String packageName;
  final String appName;
  final int usageMinutes;
  final AppCategory category;
  final DateTime lastUsed;

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
    required this.category,
    required this.lastUsed,
  });

  factory AppUsageInfo.fromMap(Map<dynamic, dynamic> map) {
    final packageName = map['packageName'] as String? ?? '';
    return AppUsageInfo(
      packageName: packageName,
      appName: map['appName'] as String? ?? packageName.split('.').last,
      usageMinutes: (map['usageTime'] as int? ?? 0) ~/ 60000, // Convert ms to minutes
      category: _categorizeApp(packageName),
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] as int? ?? 0),
    );
  }

  static AppCategory _categorizeApp(String packageName) {
    if (islamicApps.contains(packageName)) return AppCategory.islamic;
    if (productiveApps.contains(packageName)) return AppCategory.productive;
    if (socialApps.contains(packageName)) return AppCategory.social;
    if (entertainmentApps.contains(packageName)) return AppCategory.entertainment;
    if (messagingApps.contains(packageName)) return AppCategory.messaging;
    if (packageName.toLowerCase().contains('game')) return AppCategory.entertainment;
    return AppCategory.utility;
  }
}

/// Daily usage summary
class DailyUsageSummary {
  final DateTime date;
  final int totalMinutes;
  final int islamicMinutes;
  final int productiveMinutes;
  final int socialMinutes;
  final int entertainmentMinutes;
  final int messagingMinutes;
  final int utilityMinutes;
  final List<AppUsageInfo> topApps;
  final int pickupCount;

  DailyUsageSummary({
    required this.date,
    required this.totalMinutes,
    required this.islamicMinutes,
    required this.productiveMinutes,
    required this.socialMinutes,
    required this.entertainmentMinutes,
    required this.messagingMinutes,
    required this.utilityMinutes,
    required this.topApps,
    this.pickupCount = 0,
  });

  factory DailyUsageSummary.empty(DateTime date) {
    return DailyUsageSummary(
      date: date,
      totalMinutes: 0,
      islamicMinutes: 0,
      productiveMinutes: 0,
      socialMinutes: 0,
      entertainmentMinutes: 0,
      messagingMinutes: 0,
      utilityMinutes: 0,
      topApps: [],
    );
  }

  /// Islamic engagement ratio (0-100)
  double get islamicRatio => totalMinutes > 0 
      ? (islamicMinutes / totalMinutes) * 100 
      : 0;

  /// Productive ratio (Islamic + Productive)
  double get productiveRatio => totalMinutes > 0 
      ? ((islamicMinutes + productiveMinutes) / totalMinutes) * 100 
      : 0;

  /// Focus level based on engagement
  String get focusLevel {
    if (productiveRatio >= 60) return 'Master';
    if (productiveRatio >= 40) return 'Focused';
    if (productiveRatio >= 20) return 'Mindful';
    return 'Beginner';
  }

  /// Hours and minutes formatted
  String get formattedTotal {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

/// Usage stats state
class UsageStatsState {
  final bool hasPermission;
  final bool isLoading;
  final DailyUsageSummary? todaySummary;
  final List<DailyUsageSummary> weeklyData;
  final String? error;

  UsageStatsState({
    this.hasPermission = false,
    this.isLoading = false,
    this.todaySummary,
    this.weeklyData = const [],
    this.error,
  });

  UsageStatsState copyWith({
    bool? hasPermission,
    bool? isLoading,
    DailyUsageSummary? todaySummary,
    List<DailyUsageSummary>? weeklyData,
    String? error,
  }) {
    return UsageStatsState(
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      todaySummary: todaySummary ?? this.todaySummary,
      weeklyData: weeklyData ?? this.weeklyData,
      error: error,
    );
  }
}

/// Usage stats notifier
class UsageStatsNotifier extends StateNotifier<UsageStatsState> {
  static const _channel = MethodChannel('com.minimalist.launcher/usage_stats');
  
  UsageStatsNotifier() : super(UsageStatsState()) {
    _init();
  }

  Future<void> _init() async {
    await checkPermission();
    if (state.hasPermission) {
      await loadUsageData();
    }
  }

  /// Check if we have usage stats permission
  Future<bool> checkPermission() async {
    try {
      final hasPermission = await _channel.invokeMethod<bool>('hasPermission') ?? false;
      state = state.copyWith(hasPermission: hasPermission);
      return hasPermission;
    } catch (e) {
      // Platform not supported or error
      state = state.copyWith(hasPermission: false, error: 'Permission check failed');
      return false;
    }
  }

  /// Request usage stats permission
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
      // User will be taken to settings, check permission on resume
    } catch (e) {
      state = state.copyWith(error: 'Failed to request permission');
    }
  }

  /// Load usage data
  Future<void> loadUsageData() async {
    if (!state.hasPermission) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get today's stats
      final todayData = await _getUsageForDate(DateTime.now());
      
      // Get weekly data
      final weeklyData = <DailyUsageSummary>[];
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final data = await _getUsageForDate(date);
        weeklyData.add(data);
      }

      state = state.copyWith(
        isLoading: false,
        todaySummary: todayData,
        weeklyData: weeklyData,
      );

      // Cache data
      await _cacheData(todayData, weeklyData);
    } catch (e) {
      // Try to load from cache
      await _loadFromCache();
      state = state.copyWith(isLoading: false);
    }
  }

  Future<DailyUsageSummary> _getUsageForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await _channel.invokeMethod<List<dynamic>>('getUsageStats', {
        'startTime': startOfDay.millisecondsSinceEpoch,
        'endTime': endOfDay.millisecondsSinceEpoch,
      });

      if (result == null || result.isEmpty) {
        return DailyUsageSummary.empty(date);
      }

      final apps = result
          .map((e) => AppUsageInfo.fromMap(e as Map<dynamic, dynamic>))
          .where((app) => app.usageMinutes > 0)
          .toList()
        ..sort((a, b) => b.usageMinutes.compareTo(a.usageMinutes));

      int islamicMinutes = 0;
      int productiveMinutes = 0;
      int socialMinutes = 0;
      int entertainmentMinutes = 0;
      int messagingMinutes = 0;
      int utilityMinutes = 0;

      for (final app in apps) {
        switch (app.category) {
          case AppCategory.islamic:
            islamicMinutes += app.usageMinutes;
            break;
          case AppCategory.productive:
            productiveMinutes += app.usageMinutes;
            break;
          case AppCategory.social:
            socialMinutes += app.usageMinutes;
            break;
          case AppCategory.entertainment:
            entertainmentMinutes += app.usageMinutes;
            break;
          case AppCategory.messaging:
            messagingMinutes += app.usageMinutes;
            break;
          case AppCategory.utility:
            utilityMinutes += app.usageMinutes;
            break;
        }
      }

      return DailyUsageSummary(
        date: date,
        totalMinutes: islamicMinutes + productiveMinutes + socialMinutes + 
                      entertainmentMinutes + messagingMinutes + utilityMinutes,
        islamicMinutes: islamicMinutes,
        productiveMinutes: productiveMinutes,
        socialMinutes: socialMinutes,
        entertainmentMinutes: entertainmentMinutes,
        messagingMinutes: messagingMinutes,
        utilityMinutes: utilityMinutes,
        topApps: apps.take(5).toList(),
      );
    } catch (e) {
      return DailyUsageSummary.empty(date);
    }
  }

  Future<void> _cacheData(
    DailyUsageSummary today,
    List<DailyUsageSummary> weekly,
  ) async {
    try {
      final box = await Hive.openBox('usageStatsCache');
      await box.put('lastUpdated', DateTime.now().millisecondsSinceEpoch);
      await box.put('todayMinutes', today.totalMinutes);
      await box.put('todayIslamic', today.islamicMinutes);
      await box.put('todayProductive', today.productiveMinutes);
      await box.put('todaySocial', today.socialMinutes);
      await box.put('todayEntertainment', today.entertainmentMinutes);
    } catch (_) {}
  }

  Future<void> _loadFromCache() async {
    try {
      final box = await Hive.openBox('usageStatsCache');
      final totalMinutes = box.get('todayMinutes', defaultValue: 0) as int;
      
      if (totalMinutes > 0) {
        state = state.copyWith(
          todaySummary: DailyUsageSummary(
            date: DateTime.now(),
            totalMinutes: totalMinutes,
            islamicMinutes: box.get('todayIslamic', defaultValue: 0) as int,
            productiveMinutes: box.get('todayProductive', defaultValue: 0) as int,
            socialMinutes: box.get('todaySocial', defaultValue: 0) as int,
            entertainmentMinutes: box.get('todayEntertainment', defaultValue: 0) as int,
            messagingMinutes: 0,
            utilityMinutes: 0,
            topApps: [],
          ),
        );
      }
    } catch (_) {}
  }

  /// Refresh data
  Future<void> refresh() async {
    final hasPermission = await checkPermission();
    if (hasPermission) {
      await loadUsageData();
    }
  }
}

/// Providers
final usageStatsProvider = StateNotifierProvider<UsageStatsNotifier, UsageStatsState>((ref) {
  return UsageStatsNotifier();
});

/// Convenience providers
final todayUsageProvider = Provider<DailyUsageSummary?>((ref) {
  return ref.watch(usageStatsProvider).todaySummary;
});

final weeklyUsageProvider = Provider<List<DailyUsageSummary>>((ref) {
  return ref.watch(usageStatsProvider).weeklyData;
});

final hasUsagePermissionProvider = Provider<bool>((ref) {
  return ref.watch(usageStatsProvider).hasPermission;
});
