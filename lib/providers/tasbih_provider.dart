import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Tasbih state model - stores count per dhikr
class TasbihState {
  final Map<int, int> dhikrCounts; // Count per dhikr index
  final int targetCount;
  final int totalAllTime;
  final int todayCount;
  final String lastDate;
  final int selectedDhikrIndex;

  TasbihState({
    Map<int, int>? dhikrCounts,
    this.targetCount = 33,
    this.totalAllTime = 0,
    this.todayCount = 0,
    this.lastDate = '',
    this.selectedDhikrIndex = 0,
  }) : dhikrCounts = dhikrCounts ?? {};

  // Get current count for selected dhikr
  int get currentCount => dhikrCounts[selectedDhikrIndex] ?? 0;

  TasbihState copyWith({
    Map<int, int>? dhikrCounts,
    int? targetCount,
    int? totalAllTime,
    int? todayCount,
    String? lastDate,
    int? selectedDhikrIndex,
  }) {
    return TasbihState(
      dhikrCounts: dhikrCounts ?? this.dhikrCounts,
      targetCount: targetCount ?? this.targetCount,
      totalAllTime: totalAllTime ?? this.totalAllTime,
      todayCount: todayCount ?? this.todayCount,
      lastDate: lastDate ?? this.lastDate,
      selectedDhikrIndex: selectedDhikrIndex ?? this.selectedDhikrIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'dhikrCounts': dhikrCounts.map((k, v) => MapEntry(k.toString(), v)),
    'targetCount': targetCount,
    'totalAllTime': totalAllTime,
    'todayCount': todayCount,
    'lastDate': lastDate,
    'selectedDhikrIndex': selectedDhikrIndex,
  };

  factory TasbihState.fromJson(Map<String, dynamic> json) {
    // Parse dhikrCounts
    Map<int, int> counts = {};
    if (json['dhikrCounts'] != null) {
      final rawCounts = json['dhikrCounts'] as Map<String, dynamic>;
      counts = rawCounts.map((k, v) => MapEntry(int.parse(k), v as int));
    }
    // Migration: if old format with currentCount, migrate it
    if (json['currentCount'] != null && counts.isEmpty) {
      final oldCount = json['currentCount'] as int? ?? 0;
      final oldIndex = json['selectedDhikrIndex'] as int? ?? 0;
      counts[oldIndex] = oldCount;
    }
    
    return TasbihState(
      dhikrCounts: counts,
      targetCount: json['targetCount'] as int? ?? 33,
      totalAllTime: json['totalAllTime'] as int? ?? 0,
      todayCount: json['todayCount'] as int? ?? 0,
      lastDate: json['lastDate'] as String? ?? '',
      selectedDhikrIndex: json['selectedDhikrIndex'] as int? ?? 0,
    );
  }
}

/// Dhikr preset with more options
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
    // Core Tasbihat (After Salah)
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
    // Kalimah
    Dhikr(
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illallah',
      meaning: 'There is no god but Allah',
      defaultTarget: 100,
    ),
    // Istighfar
    Dhikr(
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah',
      defaultTarget: 100,
    ),
    Dhikr(
      arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
      transliteration: 'Astaghfirullah al-Azeem',
      meaning: 'I seek forgiveness from Allah, the Mighty',
      defaultTarget: 100,
    ),
    // SubhanAllah variations
    Dhikr(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory and praise be to Allah',
      defaultTarget: 100,
    ),
    Dhikr(
      arabic: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      transliteration: 'SubhanAllah al-Azeem',
      meaning: 'Glory be to Allah, the Mighty',
      defaultTarget: 100,
    ),
    // Salawat
    Dhikr(
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      transliteration: 'Allahumma salli ala Muhammad',
      meaning: 'O Allah, send blessings upon Muhammad',
      defaultTarget: 100,
    ),
    // Power of Allah
    Dhikr(
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      meaning: 'There is no power except with Allah',
      defaultTarget: 100,
    ),
    // Combined Tasbeeh
    Dhikr(
      arabic: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      transliteration: 'SubhanAllah wal Hamdulillah...',
      meaning: 'Glory to Allah, Praise to Allah, No god but Allah, Allah is Great',
      defaultTarget: 100,
    ),
    // Ya Allah
    Dhikr(
      arabic: 'يَا اللَّهُ',
      transliteration: 'Ya Allah',
      meaning: 'O Allah',
      defaultTarget: 100,
    ),
    // Ya Rahman
    Dhikr(
      arabic: 'يَا رَحْمَٰنُ',
      transliteration: 'Ya Rahman',
      meaning: 'O Most Merciful',
      defaultTarget: 100,
    ),
    // Ya Raheem
    Dhikr(
      arabic: 'يَا رَحِيمُ',
      transliteration: 'Ya Raheem',
      meaning: 'O Most Compassionate',
      defaultTarget: 100,
    ),
    // Custom counter
    Dhikr(
      arabic: '...',
      transliteration: 'Custom Count',
      meaning: 'Use for any dhikr',
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
        // Set target to current dhikr's default
        final dhikr = Dhikr.presets[state.selectedDhikrIndex];
        state = state.copyWith(targetCount: dhikr.defaultTarget);
      } catch (e) {
        // Use default
      }
    }
  }

  void _checkNewDay() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (state.lastDate != today) {
      // New day - reset today count but keep dhikr counts
      state = state.copyWith(
        todayCount: 0,
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
    // Update count for current dhikr
    final newCounts = Map<int, int>.from(state.dhikrCounts);
    newCounts[state.selectedDhikrIndex] = (newCounts[state.selectedDhikrIndex] ?? 0) + 1;
    
    state = state.copyWith(
      dhikrCounts: newCounts,
      totalAllTime: state.totalAllTime + 1,
      todayCount: state.todayCount + 1,
      lastDate: DateTime.now().toIso8601String().split('T')[0],
    );
    _save();
  }

  void reset() {
    // Reset only current dhikr's count
    final newCounts = Map<int, int>.from(state.dhikrCounts);
    newCounts[state.selectedDhikrIndex] = 0;
    state = state.copyWith(dhikrCounts: newCounts);
    _save();
  }

  void setTarget(int target) {
    state = state.copyWith(targetCount: target);
    _save();
  }

  void selectDhikr(int index) {
    if (index < 0 || index >= Dhikr.presets.length) return;
    
    final dhikr = Dhikr.presets[index];
    // Don't reset count - just switch dhikr and update target
    state = state.copyWith(
      selectedDhikrIndex: index,
      targetCount: dhikr.defaultTarget,
    );
    _save();
  }

  void resetAllTime() {
    state = state.copyWith(
      totalAllTime: 0, 
      todayCount: 0,
      dhikrCounts: {},
    );
    _save();
  }
  
  // Get count for a specific dhikr
  int getCountForDhikr(int index) {
    return state.dhikrCounts[index] ?? 0;
  }
}
