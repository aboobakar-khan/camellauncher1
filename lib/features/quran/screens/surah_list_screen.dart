import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';
import 'surah_reader_screen.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahs = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSurahs(List<Surah> allSurahs, String query) {
    if (query.isEmpty) {
      _filteredSurahs = allSurahs;
    } else {
      _filteredSurahs = allSurahs.where((surah) {
        final searchLower = query.toLowerCase();
        return surah.name.toLowerCase().contains(searchLower) ||
            surah.transliteration.toLowerCase().contains(searchLower) ||
            surah.id.toString().contains(searchLower);
      }).toList();
    }
  }

  void _navigateToSurah(Surah surah, {int? scrollToAyah}) {
    ref.read(selectedSurahProvider.notifier).state = surah;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahReaderScreen(
          surah: surah,
          initialAyah: scrollToAyah,
        ),
      ),
    );
  }

  Future<void> _resumeReading(LastReadPosition position, List<Surah> surahs) async {
    HapticFeedback.mediumImpact();
    
    // Find the surah
    final surah = surahs.firstWhere(
      (s) => s.id == position.surahId,
      orElse: () => surahs.first,
    );
    
    _navigateToSurah(surah, scrollToAyah: position.ayahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    final readingProgress = ref.watch(readingProgressProvider);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Column(
        children: [
          // Resume Reading Card
          if (!readingProgress.isLoading && readingProgress.lastPosition != null)
            surahsAsync.when(
              data: (surahs) => _buildResumeReadingCard(readingProgress.lastPosition!, surahs),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Surah...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 147, 244, 150),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Surah List
          Expanded(
            child: surahsAsync.when(
              data: (surahs) {
                _filterSurahs(surahs, _searchController.text);

                if (_filteredSurahs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Surah found',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  cacheExtent: 500,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            '${surah.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                surah.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              surah.transliteration,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              surah.type == 'meccan' ? 'Meccan' : 'Medinan',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${surah.totalVerses} verses',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 147, 244, 150),
                          size: 16,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToSurah(surah);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading Quran: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeReadingCard(LastReadPosition position, List<Surah> surahs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF40C463).withValues(alpha: 0.3),
            const Color(0xFF30A14E).withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF40C463).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _resumeReading(position, surahs),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Book icon with progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: position.progressPercentage / 100,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF40C463),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.book_outlined,
                      color: Color(0xFF40C463),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            color: Color(0xFF40C463),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Resume Reading',
                            style: TextStyle(
                              color: Color(0xFF40C463),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position.surahTransliteration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ayah ${position.ayahNumber} of ${position.totalVerses}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C463).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF40C463),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
