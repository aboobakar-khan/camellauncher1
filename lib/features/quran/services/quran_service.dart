import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../models/verse.dart';

class QuranService {
  Future<List<Surah>> loadSurahs() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quran/quran_en.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Surah.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Verse>> loadVerses(int surahId) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quran/quran_en.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      final surahData = jsonList.firstWhere(
        (s) => s['id'] == surahId,
        orElse: () => null,
      );

      if (surahData == null) return [];

      final List<dynamic> versesJson = surahData['verses'] as List<dynamic>;
      return versesJson
          .map((json) => Verse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRandomVerse() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quran/quran_en.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Pick a random surah
      final random = Random();
      final randomSurahIndex = random.nextInt(jsonList.length);
      final surahData = jsonList[randomSurahIndex];

      final List<dynamic> verses = surahData['verses'] as List<dynamic>;
      if (verses.isEmpty) return null;

      // Pick a random verse from that surah
      final randomVerseIndex = random.nextInt(verses.length);
      final verseData = verses[randomVerseIndex];

      return {
        'surahId': surahData['id'] as int,
        'surahName': surahData['name'] as String,
        'surahTransliteration': surahData['transliteration'] as String,
        'verseNumber': verseData['id'] as int,
        'arabic': verseData['text'] as String,
        'translation': verseData['translation'] as String?,
      };
    } catch (e) {
      return null;
    }
  }
}
