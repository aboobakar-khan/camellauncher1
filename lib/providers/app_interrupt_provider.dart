import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_interrupt.dart';

class AppInterruptNotifier extends StateNotifier<Map<String, AppInterrupt>> {
  AppInterruptNotifier() : super({}) {
    _loadInterrupts();
  }

  Box<AppInterrupt>? _box;

  Future<void> _loadInterrupts() async {
    _box ??= await Hive.openBox<AppInterrupt>('app_interrupts');
    final Map<String, AppInterrupt> interrupts = {};
    for (var i = 0; i < _box!.length; i++) {
      final interrupt = _box!.getAt(i);
      if (interrupt != null) {
        interrupts[interrupt.packageName] = interrupt;
      }
    }
    state = interrupts;
  }

  Future<void> addInterrupt(AppInterrupt interrupt) async {
    _box ??= await Hive.openBox<AppInterrupt>('app_interrupts');

    // Remove existing interrupt for this package if any
    await removeInterrupt(interrupt.packageName);

    // Add new interrupt
    await _box!.add(interrupt);
    state = {...state, interrupt.packageName: interrupt};
  }

  Future<void> updateInterrupt(AppInterrupt interrupt) async {
    _box ??= await Hive.openBox<AppInterrupt>('app_interrupts');

    // Find and update existing interrupt
    for (var i = 0; i < _box!.length; i++) {
      final existing = _box!.getAt(i);
      if (existing?.packageName == interrupt.packageName) {
        await _box!.putAt(i, interrupt);
        state = {...state, interrupt.packageName: interrupt};
        return;
      }
    }

    // If not found, add it
    await addInterrupt(interrupt);
  }

  Future<void> removeInterrupt(String packageName) async {
    _box ??= await Hive.openBox<AppInterrupt>('app_interrupts');

    for (var i = 0; i < _box!.length; i++) {
      final interrupt = _box!.getAt(i);
      if (interrupt?.packageName == packageName) {
        await _box!.deleteAt(i);
        final newState = Map<String, AppInterrupt>.from(state);
        newState.remove(packageName);
        state = newState;
        return;
      }
    }
  }

  Future<void> toggleInterrupt(String packageName) async {
    final interrupt = state[packageName];
    if (interrupt != null) {
      final updated = interrupt.copyWith(isEnabled: !interrupt.isEnabled);
      await updateInterrupt(updated);
    }
  }

  AppInterrupt? getInterrupt(String packageName) {
    return state[packageName];
  }

  bool hasInterrupt(String packageName) {
    return state.containsKey(packageName) && state[packageName]!.isEnabled;
  }

  List<AppInterrupt> getAllInterrupts() {
    return state.values.toList();
  }
}

final appInterruptProvider =
    StateNotifierProvider<AppInterruptNotifier, Map<String, AppInterrupt>>(
      (ref) => AppInterruptNotifier(),
    );
