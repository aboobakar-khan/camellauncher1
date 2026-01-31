import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Tasbih state model
class TasbihState {
  final int currentCount;
  final int targetCount;
  final int totalAllTime;
  final int todayCount;
  final String lastDate;
  final int selectedDhikrIndex;

  TasbihState({
    this.currentCount = 0,
    this.targetCount = 33,
    this.totalAllTime = 0,
    this.todayCount = 0,
    this.lastDate = '',
    this.selectedDhikrIndex = 0,
  });

  TasbihState copyWith({
    int? currentCount,
    int? targetCount,
    int? totalAllTime,
    int? todayCount,
    String? lastDate,
    int? selectedDhikrIndex,
  }) {
    return TasbihState(
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      totalAllTime: totalAllTime ?? this.totalAllTime,
      todayCount: todayCount ?? this.todayCount,
      lastDate: lastDate ?? this.lastDate,
      selectedDhikrIndex: selectedDhikrIndex ?? this.selectedDhikrIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentCount': currentCount,
    'targetCount': targetCount,
    'totalAllTime': totalAllTime,
    'todayCount': todayCount,
    'lastDate': lastDate,
    'selectedDhikrIndex': selectedDhikrIndex,
  };

  factory TasbihState.fromJson(Map<String, dynamic> json) {
    return TasbihState(
      currentCount: json['currentCount'] as int? ?? 0,
      targetCount: json['targetCount'] as int? ?? 33,
      totalAllTime: json['totalAllTime'] as int? ?? 0,
      todayCount: json['todayCount'] as int? ?? 0,
      lastDate: json['lastDate'] as String? ?? '',
      selectedDhikrIndex: json['selectedDhikrIndex'] as int? ?? 0,
    );
  }
}

/// Dhikr preset
class Dhikr {
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;

  const Dhikr({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
  });

  static const List<Dhikr> presets = [
    Dhikr(
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'SubhanAllah',
      meaning: 'Glory be to Allah',
      defaultTarget: 33,
    ),
    Dhikr(
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      meaning: 'Praise be to Allah',
      defaultTarget: 33,
    ),
    Dhikr(
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      meaning: 'Allah is the Greatest',
      defaultTarget: 34,
    ),
    Dhikr(
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illallah',
      meaning: 'There is no god but Allah',
      defaultTarget: 100,
    ),
    Dhikr(
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah',
      defaultTarget: 100,
    ),
    Dhikr(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory and praise be to Allah',
      defaultTarget: 100,
    ),
  ];
}

/// Tasbih provider
final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  return TasbihNotifier();
});

class TasbihNotifier extends StateNotifier<TasbihState> {
  static const String _boxName = 'tasbih_data';
  static const String _key = 'state';
  Box<String>? _box;

  TasbihNotifier() : super(TasbihState()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<String>(_boxName);
    final saved = _box?.get(_key);
    if (saved != null) {
      try {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        state = TasbihState.fromJson(json);
        _checkNewDay();
      } catch (e) {
        // Use default
      }
    }
  }

  void _checkNewDay() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (state.lastDate != today) {
      state = state.copyWith(
        todayCount: 0,
        currentCount: 0,
        lastDate: today,
      );
      _save();
    }
  }

  Future<void> _save() async {
    _box ??= await Hive.openBox<String>(_boxName);
    await _box?.put(_key, jsonEncode(state.toJson()));
  }

  void increment() {
    final newCurrent = state.currentCount + 1;
    state = state.copyWith(
      currentCount: newCurrent,
      totalAllTime: state.totalAllTime + 1,
      todayCount: state.todayCount + 1,
      lastDate: DateTime.now().toIso8601String().split('T')[0],
    );
    _save();
  }

  void reset() {
    state = state.copyWith(currentCount: 0);
    _save();
  }

  void setTarget(int target) {
    state = state.copyWith(targetCount: target);
    _save();
  }

  void selectDhikr(int index) {
    final dhikr = Dhikr.presets[index];
    state = state.copyWith(
      selectedDhikrIndex: index,
      targetCount: dhikr.defaultTarget,
      currentCount: 0,
    );
    _save();
  }

  void resetAllTime() {
    state = state.copyWith(totalAllTime: 0, todayCount: 0);
    _save();
  }
}
