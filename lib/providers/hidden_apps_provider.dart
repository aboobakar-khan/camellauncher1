import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hidden_app.dart';

/// Provider for managing user-hidden and unhidden apps
final hiddenAppsProvider =
    StateNotifierProvider<HiddenAppsNotifier, List<HiddenApp>>((ref) {
      return HiddenAppsNotifier();
    });

class HiddenAppsNotifier extends StateNotifier<List<HiddenApp>> {
  static const String _boxName = 'hiddenApps';
  Box<HiddenApp>? _box;

  HiddenAppsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<HiddenApp>(_boxName);
    state = _box!.values.toList();
  }

  /// Check if an app is hidden by user
  bool isHiddenByUser(String packageName) {
    return state.any(
      (app) => app.packageName == packageName && app.isHiddenByUser,
    );
  }

  /// Check if an app is unhidden (user override to show a filtered app)
  bool isUnhiddenByUser(String packageName) {
    return state.any(
      (app) => app.packageName == packageName && !app.isHiddenByUser,
    );
  }

  /// Hide an app (user action)
  Future<void> hideApp(String packageName, String appName) async {
    if (_box == null) return;

    // Always create a new HiddenApp with isHiddenByUser: true
    final updated = HiddenApp(
      packageName: packageName,
      appName: appName,
      isHiddenByUser: true,
      lastModified: DateTime.now(),
    );

    await _box!.put(packageName, updated);
    state = _box!.values.toList();
  }

  /// Unhide an app (user override to show a filtered app)
  Future<void> unhideApp(String packageName, String appName) async {
    if (_box == null) return;

    // Always create a new HiddenApp with isHiddenByUser: false
    final updated = HiddenApp(
      packageName: packageName,
      appName: appName,
      isHiddenByUser: false,
      lastModified: DateTime.now(),
    );

    await _box!.put(packageName, updated);
    state = _box!.values.toList();
  }

  /// Remove app from hidden list entirely
  Future<void> removeFromList(String packageName) async {
    if (_box == null) return;

    await _box!.delete(packageName);
    state = _box!.values.toList();
  }

  /// Clear all hidden apps
  Future<void> clearAll() async {
    if (_box == null) return;

    await _box!.clear();
    state = [];
  }
}
