import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../features/quran/services/tafseer_service.dart';
import '../features/hadith_dua/services/hadith_dua_service.dart';
import '../features/hadith_dua/models/hadith_dua_models.dart';
import 'dart:convert';

/// Offline Content Download Manager
/// 
/// Best practices implemented:
/// - Auto-download on first launch when internet available
/// - Background downloading (non-blocking UI)
/// - Progress tracking with persistence
/// - Retry mechanism on failure
/// - Connectivity-aware (pauses when offline)
/// - Minimal impact on app performance

class DownloadStatus {
  final bool isDownloading;
  final double progress; // 0.0 to 1.0
  final String? currentItem;
  final bool tafseerComplete;
  final bool hadithComplete;
  final bool duaComplete;
  final String? error;

  const DownloadStatus({
    this.isDownloading = false,
    this.progress = 0.0,
    this.currentItem,
    this.tafseerComplete = false,
    this.hadithComplete = false,
    this.duaComplete = false,
    this.error,
  });

  DownloadStatus copyWith({
    bool? isDownloading,
    double? progress,
    String? currentItem,
    bool? tafseerComplete,
    bool? hadithComplete,
    bool? duaComplete,
    String? error,
  }) {
    return DownloadStatus(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      currentItem: currentItem ?? this.currentItem,
      tafseerComplete: tafseerComplete ?? this.tafseerComplete,
      hadithComplete: hadithComplete ?? this.hadithComplete,
      duaComplete: duaComplete ?? this.duaComplete,
      error: error,
    );
  }

  bool get isComplete => tafseerComplete && hadithComplete && duaComplete;
  
  double get overallProgress {
    int completed = 0;
    if (tafseerComplete) completed++;
    if (hadithComplete) completed++;
    if (duaComplete) completed++;
    return completed / 3.0;
  }
}

class OfflineContentManager extends StateNotifier<DownloadStatus> {
  static const String _boxName = 'offline_content';
  static const String _statusKey = 'download_status';
  static const String _hadithCacheKey = 'hadith_cache';
  static const String _duaCacheKey = 'dua_cache';
  
  Box<String>? _box;
  final TafseerService _tafseerService = TafseerService();
  final HadithDuaService _hadithService = HadithDuaService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  OfflineContentManager() : super(const DownloadStatus()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      await _tafseerService.init();
      
      // Load saved status
      final savedStatus = _box?.get(_statusKey);
      if (savedStatus != null) {
        try {
          final json = jsonDecode(savedStatus) as Map<String, dynamic>;
          state = DownloadStatus(
            tafseerComplete: json['tafseerComplete'] as bool? ?? false,
            hadithComplete: json['hadithComplete'] as bool? ?? false,
            duaComplete: json['duaComplete'] as bool? ?? false,
          );
        } catch (e) {
          debugPrint('Error loading download status: $e');
        }
      }
      
      _isInitialized = true;
      
      // Listen for connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _onConnectivityChanged,
      );
      
      // Check if first launch and start download
      if (!state.isComplete) {
        _checkAndStartDownload();
      }
    } catch (e) {
      debugPrint('OfflineContentManager init error: $e');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasInternet = results.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet
    );
    
    if (hasInternet && !state.isComplete && !state.isDownloading) {
      _checkAndStartDownload();
    }
  }

  Future<void> _checkAndStartDownload() async {
    if (!_isInitialized || state.isDownloading) return;
    
    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet
    );
    
    if (!hasInternet) return;
    
    // Start background download
    startBackgroundDownload();
  }

  /// Start downloading all offline content
  Future<void> startBackgroundDownload() async {
    if (state.isDownloading || state.isComplete) return;
    
    state = state.copyWith(isDownloading: true, error: null);
    
    try {
      // 1. Download Duas first (smallest, instant value)
      if (!state.duaComplete) {
        await _downloadDuas();
      }
      
      // 2. Download Hadiths (medium size)
      if (!state.hadithComplete) {
        await _downloadHadiths();
      }
      
      // 3. Download Tafseer (largest, most important)
      if (!state.tafseerComplete) {
        await _downloadTafseer();
      }
      
      state = state.copyWith(isDownloading: false);
    } catch (e) {
      debugPrint('Download error: $e');
      state = state.copyWith(
        isDownloading: false,
        error: 'Download paused. Will retry when connected.',
      );
    }
  }

  Future<void> _downloadDuas() async {
    state = state.copyWith(currentItem: 'Downloading Duas...');
    
    try {
      final duas = _hadithService.getCuratedDuas();
      
      // Cache duas locally using toJson
      final duaJson = jsonEncode(duas.map((d) => d.toJson()).toList());
      
      await _box?.put(_duaCacheKey, duaJson);
      
      state = state.copyWith(duaComplete: true, progress: 0.33);
      await _saveStatus();
    } catch (e) {
      debugPrint('Dua download error: $e');
      // Don't fail completely, continue with other downloads
    }
  }

  Future<void> _downloadHadiths() async {
    state = state.copyWith(currentItem: 'Downloading Hadiths...');
    
    try {
      // Download from main collections (Bukhari and Muslim)
      final collections = [
        HadithCollection.fromId('bukhari'),
        HadithCollection.fromId('muslim'),
      ];
      
      List<Map<String, dynamic>> allHadiths = [];
      
      for (int i = 0; i < collections.length; i++) {
        state = state.copyWith(
          currentItem: 'Downloading ${collections[i].name}...',
          progress: 0.33 + (i / collections.length) * 0.33,
        );
        
        try {
          // Fetch a good sample of hadiths (not all, to save space)
          final hadiths = await _hadithService.fetchRandomSections(
            collections[i],
            sections: 5, // Get 5 random sections
          );
          
          for (final hadith in hadiths) {
            allHadiths.add({
              'hadithNumber': hadith.hadithNumber,
              'arabicNumber': hadith.arabicNumber,
              'text': hadith.text,
              'arabicText': hadith.arabicText,
              'narrator': hadith.narrator,
              'collection': hadith.collection,
              'book': hadith.book,
              'hadithInBook': hadith.hadithInBook,
              'section': hadith.section,
              'chapterName': hadith.chapterName,
              'grade': hadith.grade.name,
            });
          }
        } catch (e) {
          debugPrint('Error downloading ${collections[i].name}: $e');
        }
      }
      
      // Cache hadiths locally
      if (allHadiths.isNotEmpty) {
        await _box?.put(_hadithCacheKey, jsonEncode(allHadiths));
      }
      
      state = state.copyWith(hadithComplete: true, progress: 0.66);
      await _saveStatus();
    } catch (e) {
      debugPrint('Hadith download error: $e');
    }
  }

  Future<void> _downloadTafseer() async {
    state = state.copyWith(currentItem: 'Downloading Tafseer...');
    
    try {
      // Download tafseer for first 10 surahs (most commonly read)
      // This is a reasonable amount for offline access
      final prioritySurahs = [1, 2, 3, 18, 36, 55, 56, 67, 78, 112, 113, 114];
      final surahVerses = {
        1: 7, 2: 286, 3: 200, 18: 110, 36: 83, 55: 78,
        56: 96, 67: 30, 78: 40, 112: 4, 113: 5, 114: 6,
      };
      
      int completed = 0;
      
      for (final surahId in prioritySurahs) {
        state = state.copyWith(
          currentItem: 'Downloading Tafseer: Surah $surahId',
          progress: 0.66 + (completed / prioritySurahs.length) * 0.34,
        );
        
        try {
          final verses = surahVerses[surahId] ?? 7;
          await _tafseerService.downloadSurahTafseer(
            surahId,
            verses,
          );
          completed++;
        } catch (e) {
          debugPrint('Error downloading tafseer for surah $surahId: $e');
        }
        
        // Small delay to not overwhelm the API
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      state = state.copyWith(tafseerComplete: true, progress: 1.0);
      await _saveStatus();
    } catch (e) {
      debugPrint('Tafseer download error: $e');
    }
  }

  Future<void> _saveStatus() async {
    try {
      final json = jsonEncode({
        'tafseerComplete': state.tafseerComplete,
        'hadithComplete': state.hadithComplete,
        'duaComplete': state.duaComplete,
      });
      await _box?.put(_statusKey, json);
    } catch (e) {
      debugPrint('Error saving status: $e');
    }
  }

  /// Get cached hadiths for offline use
  Future<List<Hadith>> getCachedHadiths() async {
    try {
      final cached = _box?.get(_hadithCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((json) {
          final map = json as Map<String, dynamic>;
          return Hadith(
            hadithNumber: map['hadithNumber'] as int? ?? 0,
            arabicNumber: map['arabicNumber'] as int? ?? 0,
            text: map['text'] as String? ?? '',
            arabicText: map['arabicText'] as String?,
            narrator: map['narrator'] as String?,
            collection: map['collection'] as String? ?? 'Unknown',
            book: map['book'] as int? ?? 0,
            hadithInBook: map['hadithInBook'] as int? ?? 0,
            section: map['section'] as String?,
            chapterName: map['chapterName'] as String?,
            grade: map['grade'] != null 
                ? HadithGrade.values.firstWhere(
                    (g) => g.name == map['grade'],
                    orElse: () => HadithGrade.unknown,
                  )
                : HadithGrade.unknown,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getting cached hadiths: $e');
    }
    return [];
  }

  /// Get cached duas for offline use
  Future<List<Dua>> getCachedDuas() async {
    try {
      final cached = _box?.get(_duaCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        return list.map((json) {
          final map = json as Map<String, dynamic>;
          return Dua.fromJson(map);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getting cached duas: $e');
    }
    return [];
  }

  /// Clear all downloaded content
  Future<void> clearAllDownloads() async {
    await _box?.clear();
    await _tafseerService.clearCache();
    state = const DownloadStatus();
  }

  /// Retry failed downloads
  Future<void> retryDownload() async {
    state = state.copyWith(error: null);
    await startBackgroundDownload();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider for offline content manager
final offlineContentProvider = StateNotifierProvider<OfflineContentManager, DownloadStatus>(
  (ref) => OfflineContentManager(),
);
