import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Provider for storing quick action app selections (phone, camera, etc.)
final quickActionProvider =
    StateNotifierProvider<QuickActionNotifier, QuickActions>((ref) {
      return QuickActionNotifier();
    });

class QuickActions {
  final String? phoneApp;
  final String? cameraApp;

  QuickActions({this.phoneApp, this.cameraApp});

  QuickActions copyWith({String? phoneApp, String? cameraApp}) {
    return QuickActions(
      phoneApp: phoneApp ?? this.phoneApp,
      cameraApp: cameraApp ?? this.cameraApp,
    );
  }
}

class QuickActionNotifier extends StateNotifier<QuickActions> {
  static const String _boxName = 'quickActions';
  Box? _box;

  QuickActionNotifier() : super(QuickActions()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _loadFromHive();
  }

  void _loadFromHive() {
    final phoneApp = _box?.get('phoneApp') as String?;
    final cameraApp = _box?.get('cameraApp') as String?;
    state = QuickActions(phoneApp: phoneApp, cameraApp: cameraApp);
  }

  Future<void> setPhoneApp(String packageName) async {
    if (_box == null) return;
    await _box?.put('phoneApp', packageName);
    state = state.copyWith(phoneApp: packageName);
  }

  Future<void> setCameraApp(String packageName) async {
    if (_box == null) return;
    await _box?.put('cameraApp', packageName);
    state = state.copyWith(cameraApp: packageName);
  }

  void clearPhoneApp() {
    _box?.delete('phoneApp');
    state = state.copyWith(phoneApp: null);
  }

  void clearCameraApp() {
    _box?.delete('cameraApp');
    state = state.copyWith(cameraApp: null);
  }
}
