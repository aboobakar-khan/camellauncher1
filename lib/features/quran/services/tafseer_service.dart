import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/tafseer.dart';

/// Service for fetching and caching Tafseer (Quran commentary)
/// 
/// Cache Strategy:
/// - Downloads store whole surah tafseer as individual verse entries
/// - Retrieval checks cache first, then falls back to API
/// - Works fully offline once downloaded
class TafseerService {
  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';
  static const String _defaultEdition = 'en-tafisr-ibn-kathir';
  static const String _cacheBoxName = 'tafseer_cache';
  
  static Box<String>? _cacheBox;
  static bool _isInitialized = false;

  /// Initialize the cache box (singleton pattern for shared access)
  Future<void> init() async {
    if (_isInitialized && _cacheBox != null && _cacheBox!.isOpen) {
      return;
    }
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
    _isInitialized = true;
    debugPrint('TafseerService: Initialized, cache has ${_cacheBox?.length ?? 0} entries');
  }

  /// Get tafseer for a specific ayah - CACHE FIRST approach
  Future<Tafseer?> getTafseer(int surahId, int ayahId, {String? edition}) async {
    await init();
    final requestedEdition = edition ?? _defaultEdition;
    final cacheKey = '$requestedEdition-$surahId-$ayahId';

    // 1. ALWAYS check cache first (most important for offline!)
    try {
      final cached = _cacheBox?.get(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint('TafseerService: ✓ Cache HIT for $surahId:$ayahId');
        final json = jsonDecode(cached) as Map<String, dynamic>;
        final text = json['text'] as String? ?? '';
        if (text.isNotEmpty) {
          return Tafseer(
            surahId: surahId,
            ayahId: ayahId,
            text: text,
            edition: requestedEdition,
          );
        }
      }
    } catch (e) {
      debugPrint('TafseerService: Cache read error: $e');
    }

    // 2. If requested edition not in cache, try default edition cache (for offline)
    if (requestedEdition != _defaultEdition) {
      final defaultCacheKey = '$_defaultEdition-$surahId-$ayahId';
      try {
        final defaultCached = _cacheBox?.get(defaultCacheKey);
        if (defaultCached != null && defaultCached.isNotEmpty) {
          debugPrint('TafseerService: ✓ Fallback cache HIT for $surahId:$ayahId');
          final json = jsonDecode(defaultCached) as Map<String, dynamic>;
          final text = json['text'] as String? ?? '';
          if (text.isNotEmpty) {
            return Tafseer(
              surahId: surahId,
              ayahId: ayahId,
              text: text,
              edition: _defaultEdition,
            );
          }
        }
      } catch (e) {
        debugPrint('TafseerService: Fallback cache error: $e');
      }
    }

    debugPrint('TafseerService: Cache MISS for $surahId:$ayahId, trying API...');

    // 3. Try to fetch from API (only if not in cache)
    return await _fetchAndCacheTafseer(surahId, ayahId, requestedEdition);
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
        final text = json['text'] as String? ?? '';
        
        if (text.isEmpty) {
          debugPrint('TafseerService: API returned empty text for $surahId:$ayahId');
          return null;
        }

        // Cache it
        final cacheKey = '$edition-$surahId-$ayahId';
        await _cacheBox?.put(cacheKey, jsonEncode({'text': text}));
        debugPrint('TafseerService: ✓ Fetched and cached $surahId:$ayahId');

        return Tafseer(
          surahId: surahId,
          ayahId: ayahId,
          text: text,
          edition: edition,
        );
      } else {
        debugPrint('TafseerService: API returned ${response.statusCode} for $surahId:$ayahId');
      }
    } catch (e) {
      debugPrint('TafseerService: Fetch error for $surahId:$ayahId - $e');
    }
    return null;
  }

  /// Download entire surah tafseer for offline reading
  Future<bool> downloadSurahTafseer(int surahId, int totalVerses, {String? edition, Function(int, int)? onProgress}) async {
    await init();
    final ed = edition ?? _defaultEdition;

    try {
      final url = '$_baseUrl/$ed/$surahId.json';
      debugPrint('TafseerService: Downloading surah $surahId from $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Handle different API response structures
        List<dynamic> tafsirs = [];
        if (json.containsKey('tafsirs')) {
          tafsirs = json['tafsirs'] as List<dynamic>? ?? [];
        } else if (json.containsKey('ayahs')) {
          tafsirs = json['ayahs'] as List<dynamic>? ?? [];
        }

        if (tafsirs.isEmpty) {
          debugPrint('TafseerService: No tafsirs found in response for surah $surahId');
          debugPrint('TafseerService: Response keys: ${json.keys.toList()}');
          return false;
        }

        int savedCount = 0;
        for (int i = 0; i < tafsirs.length; i++) {
          final item = tafsirs[i] as Map<String, dynamic>;
          
          // Try different field names for verse number
          int? ayahId = item['verse_number'] as int?;
          ayahId ??= item['ayah'] as int?;
          ayahId ??= item['verse'] as int?;
          ayahId ??= item['aya'] as int?;
          ayahId ??= (i + 1); // Default to index + 1
          
          // Try different field names for text
          String? text = item['text'] as String?;
          text ??= item['tafsir'] as String?;
          text ??= item['content'] as String?;
          text ??= '';

          if (text.isNotEmpty) {
            final cacheKey = '$ed-$surahId-$ayahId';
            await _cacheBox?.put(cacheKey, jsonEncode({'text': text}));
            savedCount++;
          }

          onProgress?.call(i + 1, tafsirs.length);
        }

        // Mark surah as downloaded
        await _cacheBox?.put('downloaded-$ed-$surahId', 'true');
        debugPrint('TafseerService: Saved $savedCount verses for surah $surahId');
        return savedCount > 0;
      } else {
        debugPrint('TafseerService: Download failed with status ${response.statusCode} for surah $surahId');
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

  /// Debug: Get cache stats
  Future<Map<String, dynamic>> getCacheStats() async {
    await init();
    final keys = _cacheBox?.keys.toList() ?? [];
    final downloadedSurahs = keys.where((k) => k.toString().startsWith('downloaded-')).length;
    final verseEntries = keys.length - downloadedSurahs;
    return {
      'totalEntries': keys.length,
      'downloadedSurahs': downloadedSurahs,
      'verseEntries': verseEntries,
    };
  }

  /// Clear all cached tafseer
  Future<void> clearCache() async {
    await init();
    await _cacheBox?.clear();
    debugPrint('TafseerService: Cache cleared');
  }
}
