/// Tafseer model for storing Quran commentary
class Tafseer {
  final int surahId;
  final int ayahId;
  final String text;
  final String edition;

  Tafseer({
    required this.surahId,
    required this.ayahId,
    required this.text,
    required this.edition,
  });

  factory Tafseer.fromJson(Map<String, dynamic> json, int surahId, int ayahId, String edition) {
    return Tafseer(
      surahId: surahId,
      ayahId: ayahId,
      text: json['text'] as String? ?? '',
      edition: edition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahId': surahId,
      'ayahId': ayahId,
      'text': text,
      'edition': edition,
    };
  }

  /// Get cache key for this tafseer
  String get cacheKey => '$edition-$surahId-$ayahId';
}
