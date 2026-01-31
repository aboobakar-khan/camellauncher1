import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/tafseer.dart';

/// Service for fetching and caching Tafseer (Quran commentary)
class TafseerService {
  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';
  static const String _defaultEdition = 'en-tafisr-ibn-kathir';
  static const String _cacheBoxName = 'tafseer_cache';
  
  Box<String>? _cacheBox;

  /// Initialize the cache box
  Future<void> init() async {
    _cacheBox ??= await Hive.openBox<String>(_cacheBoxName);
  }

  /// Get tafseer for a specific ayah (cached or fetch)
  Future<Tafseer?> getTafseer(int surahId, int ayahId, {String? edition}) async {
    await init();
    final ed = edition ?? _defaultEdition;
    final cacheKey = '$ed-$surahId-$ayahId';

    // Check cache first
    final cached = _cacheBox?.get(cacheKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return Tafseer.fromJson(json, surahId, ayahId, ed);
      } catch (e) {
        debugPrint('Cache parse error: $e');
      }
    }

    // Fetch from API
    return await _fetchAndCacheTafseer(surahId, ayahId, ed);
  }

  /// Fetch tafseer from API and cache it
  Future<Tafseer?> _fetchAndCacheTafseer(int surahId, int ayahId, String edition) async {
    try {
      final url = '$_baseUrl/$edition/$surahId/$ayahId.json';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final tafseer = Tafseer.fromJson(json, surahId, ayahId, edition);

        // Cache it
        final cacheKey = '$edition-$surahId-$ayahId';
        await _cacheBox?.put(cacheKey, jsonEncode({'text': tafseer.text}));

        return tafseer;
      }
    } catch (e) {
      debugPrint('Tafseer fetch error: $e');
    }
    return null;
  }

  /// Download entire surah tafseer for offline reading
  Future<bool> downloadSurahTafseer(int surahId, int totalVerses, {String? edition, Function(int, int)? onProgress}) async {
    await init();
    final ed = edition ?? _defaultEdition;

    try {
      final url = '$_baseUrl/$ed/$surahId.json';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final tafsirs = json['tafsirs'] as List<dynamic>? ?? [];

        for (int i = 0; i < tafsirs.length; i++) {
          final item = tafsirs[i] as Map<String, dynamic>;
          final ayahId = item['verse_number'] as int? ?? (i + 1);
          final text = item['text'] as String? ?? '';

          final cacheKey = '$ed-$surahId-$ayahId';
          await _cacheBox?.put(cacheKey, jsonEncode({'text': text}));

          onProgress?.call(i + 1, tafsirs.length);
        }

        // Mark surah as downloaded
        await _cacheBox?.put('downloaded-$ed-$surahId', 'true');
        return true;
      }
    } catch (e) {
      debugPrint('Surah tafseer download error: $e');
    }
    return false;
  }

  /// Check if surah tafseer is downloaded
  Future<bool> isSurahDownloaded(int surahId, {String? edition}) async {
    await init();
    final ed = edition ?? _defaultEdition;
    return _cacheBox?.get('downloaded-$ed-$surahId') == 'true';
  }

  /// Clear all cached tafseer
  Future<void> clearCache() async {
    await init();
    await _cacheBox?.clear();
  }
}
