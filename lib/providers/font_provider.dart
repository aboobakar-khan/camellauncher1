import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available font styles for the app
class AppFont {
  final String name;
  final String? fontFamily;

  const AppFont({required this.name, this.fontFamily});
}

/// Predefined font styles
class AppFonts {
  static const system = AppFont(name: 'System Default', fontFamily: null);

  static final roboto = AppFont(
    name: 'Roboto',
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  static final montserrat = AppFont(
    name: 'Montserrat',
    fontFamily: GoogleFonts.montserrat().fontFamily,
  );

  static final openSans = AppFont(
    name: 'Open Sans',
    fontFamily: GoogleFonts.openSans().fontFamily,
  );

  static final lato = AppFont(
    name: 'Lato',
    fontFamily: GoogleFonts.lato().fontFamily,
  );

  static final poppins = AppFont(
    name: 'Poppins',
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  static final raleway = AppFont(
    name: 'Raleway',
    fontFamily: GoogleFonts.raleway().fontFamily,
  );

  static final oswald = AppFont(
    name: 'Oswald',
    fontFamily: GoogleFonts.oswald().fontFamily,
  );

  static List<AppFont> get all => [
    system,
    roboto,
    montserrat,
    openSans,
    lato,
    poppins,
    raleway,
    oswald,
  ];
}

/// Provider for font settings
final fontProvider = StateNotifierProvider<FontNotifier, AppFont>((ref) {
  return FontNotifier();
});

class FontNotifier extends StateNotifier<AppFont> {
  static const String _boxName = 'settings';
  static const String _fontKey = 'appFont';
  Box? _box;

  FontNotifier() : super(AppFonts.system) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox(_boxName);
      final savedFontName = _box?.get(_fontKey) as String?;

      if (savedFontName != null) {
        final font = AppFonts.all.firstWhere(
          (f) => f.name == savedFontName,
          orElse: () => AppFonts.system,
        );
        state = font;
      }
    } catch (e) {
      // Handle error, use default font
      state = AppFonts.system;
    }
  }

  Future<void> setFont(AppFont font) async {
    _box ??= await Hive.openBox(_boxName);
    await _box?.put(_fontKey, font.name);
    state = font;
  }
}
