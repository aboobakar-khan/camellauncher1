import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/focus_mode.dart';

class FocusModeNotifier extends StateNotifier<FocusModeSettings> {
  FocusModeNotifier() : super(FocusModeSettings()) {
    _loadSettings();
  }

  Box<FocusModeSettings>? _box;

  Future<void> _loadSettings() async {
    _box ??= await Hive.openBox<FocusModeSettings>('focus_mode');
    final settings = _box!.get('settings');
    if (settings != null) {
      state = settings;
    }
  }

  Future<void> _saveSettings() async {
    _box ??= await Hive.openBox<FocusModeSettings>('focus_mode');
    await _box!.put('settings', state);
  }

  Future<void> toggleFocusMode() async {
    state = state.copyWith(
      isEnabled: !state.isEnabled,
      startTime: !state.isEnabled ? DateTime.now() : null,
      endTime: state.isEnabled ? DateTime.now() : null,
    );
    await _saveSettings();
  }

  Future<void> addAllowedApp(String packageName) async {
    if (!state.allowedApps.contains(packageName) && state.canAddMoreApps()) {
      final updatedList = [...state.allowedApps, packageName];
      state = state.copyWith(allowedApps: updatedList);
      await _saveSettings();
    }
  }

  Future<void> removeAllowedApp(String packageName) async {
    final updatedList = state.allowedApps
        .where((pkg) => pkg != packageName)
        .toList();
    state = state.copyWith(allowedApps: updatedList);
    await _saveSettings();
  }

  Future<void> setBlockMessage(String message) async {
    state = state.copyWith(blockMessage: message);
    await _saveSettings();
  }

  Future<void> clearAllowedApps() async {
    state = state.copyWith(allowedApps: []);
    await _saveSettings();
  }

  bool isAppAllowed(String packageName) {
    if (!state.isEnabled) return true;
    return state.isAppAllowed(packageName);
  }

  bool isAppBlocked(String packageName) {
    if (!state.isEnabled) return false;
    return !state.isAppAllowed(packageName);
  }
}

final focusModeProvider =
    StateNotifierProvider<FocusModeNotifier, FocusModeSettings>(
      (ref) => FocusModeNotifier(),
    );
