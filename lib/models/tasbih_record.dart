/// Model for tracking Tasbih/Dhikr counts
/// Note: Uses JSON serialization via the provider, not Hive TypeAdapters
class TasbihRecord {
  String id;
  String dhikrName; // e.g., "SubhanAllah", "Alhamdulillah"
  String dhikrArabic; // Arabic text
  int count;
  DateTime date; // Date only (time set to midnight)
  DateTime createdAt;
  DateTime updatedAt;

  TasbihRecord({
    required this.id,
    required this.dhikrName,
    required this.dhikrArabic,
    this.count = 0,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get date key for lookups (YYYY-MM-DD format)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create a date-only DateTime (strips time component)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  TasbihRecord copyWith({
    String? id,
    String? dhikrName,
    String? dhikrArabic,
    int? count,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TasbihRecord(
      id: id ?? this.id,
      dhikrName: dhikrName ?? this.dhikrName,
      dhikrArabic: dhikrArabic ?? this.dhikrArabic,
      count: count ?? this.count,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Predefined Dhikr types with their targets
class DhikrPreset {
  final String name;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;

  const DhikrPreset({
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
  });

  static const List<DhikrPreset> presets = [
    DhikrPreset(
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللّٰهِ',
      transliteration: 'Subḥān Allāh',
      meaning: 'Glory be to Allah',
      defaultTarget: 33,
    ),
    DhikrPreset(
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلّٰهِ',
      transliteration: 'Al-ḥamdu lillāh',
      meaning: 'Praise be to Allah',
      defaultTarget: 33,
    ),
    DhikrPreset(
      name: 'Allahu Akbar',
      arabic: 'اللّٰهُ أَكْبَرُ',
      transliteration: 'Allāhu Akbar',
      meaning: 'Allah is the Greatest',
      defaultTarget: 34,
    ),
    DhikrPreset(
      name: 'La ilaha illallah',
      arabic: 'لَا إِلٰهَ إِلَّا اللّٰهُ',
      transliteration: 'Lā ilāha illā Allāh',
      meaning: 'There is no god but Allah',
      defaultTarget: 100,
    ),
    DhikrPreset(
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللّٰهَ',
      transliteration: 'Astaghfiru Allāh',
      meaning: 'I seek forgiveness from Allah',
      defaultTarget: 100,
    ),
    DhikrPreset(
      name: 'La hawla wa la quwwata',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
      transliteration: 'Lā ḥawla wa lā quwwata illā billāh',
      meaning: 'There is no power except with Allah',
      defaultTarget: 33,
    ),
    DhikrPreset(
      name: 'SubhanAllahi wa bihamdihi',
      arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
      transliteration: 'Subḥān Allāhi wa biḥamdihi',
      meaning: 'Glory and praise be to Allah',
      defaultTarget: 100,
    ),
  ];
}
