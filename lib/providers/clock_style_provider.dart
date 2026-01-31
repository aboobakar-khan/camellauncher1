import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Available clock styles for the app
enum ClockStyle {
  digital,
  analog,
  minimalist,
  bold,
  compact,
  modern,
  retro,
  elegant,
  binary,
}

extension ClockStyleExtension on ClockStyle {
  String get name {
    switch (this) {
      case ClockStyle.digital:
        return 'Digital';
      case ClockStyle.analog:
        return 'Analog';
      case ClockStyle.minimalist:
        return 'Minimalist';
      case ClockStyle.bold:
        return 'Bold';
      case ClockStyle.compact:
        return 'Compact';
      case ClockStyle.modern:
        return 'Modern';
      case ClockStyle.retro:
        return 'Retro';
      case ClockStyle.elegant:
        return 'Elegant';
      case ClockStyle.binary:
        return 'Binary';
    }
  }

  String get description {
    switch (this) {
      case ClockStyle.digital:
        return 'Classic digital clock';
      case ClockStyle.analog:
        return 'Traditional analog clock';
      case ClockStyle.minimalist:
        return 'Simple and clean';
      case ClockStyle.bold:
        return 'Large and prominent';
      case ClockStyle.compact:
        return 'Space-saving layout';
      case ClockStyle.modern:
        return 'Sleek contemporary style';
      case ClockStyle.retro:
        return 'Vintage flip-clock style';
      case ClockStyle.elegant:
        return 'Refined and sophisticated';
      case ClockStyle.binary:
        return 'Geek mode - binary time';
    }
  }
}

/// Provider for clock style settings
final clockStyleProvider =
    StateNotifierProvider<ClockStyleNotifier, ClockStyle>((ref) {
      return ClockStyleNotifier();
    });

class ClockStyleNotifier extends StateNotifier<ClockStyle> {
  static const String _boxName = 'settings';
  static const String _clockKey = 'clockStyle';
  Box? _box;

  ClockStyleNotifier() : super(ClockStyle.digital) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox(_boxName);
      final savedStyle = _box?.get(_clockKey) as String?;

      if (savedStyle != null) {
        final style = ClockStyle.values.firstWhere(
          (s) => s.name == savedStyle,
          orElse: () => ClockStyle.digital,
        );
        state = style;
      }
    } catch (e) {
      // Handle error, use default style
      state = ClockStyle.digital;
    }
  }

  Future<void> setClockStyle(ClockStyle style) async {
    _box ??= await Hive.openBox(_boxName);
    await _box?.put(_clockKey, style.name);
    state = style;
  }
}
