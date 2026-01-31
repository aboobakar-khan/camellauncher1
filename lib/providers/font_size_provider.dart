import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final box = await Hive.openBox('settings');
    final savedSize = box.get('fontSize', defaultValue: 1.0) as double;
    state = savedSize;
  }

  Future<void> setFontSize(double size) async {
    final box = await Hive.openBox('settings');
    await box.put('fontSize', size);
    state = size;
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
  (ref) => FontSizeNotifier(),
);

// Font size presets
class FontSizePreset {
  final String name;
  final double scale;

  const FontSizePreset({required this.name, required this.scale});
}

const List<FontSizePreset> fontSizePresets = [
  FontSizePreset(name: 'Small', scale: 0.85),
  FontSizePreset(name: 'Normal (Default)', scale: 1.0),
  FontSizePreset(name: 'Medium', scale: 1.15),
  FontSizePreset(name: 'Large', scale: 1.3),
];
