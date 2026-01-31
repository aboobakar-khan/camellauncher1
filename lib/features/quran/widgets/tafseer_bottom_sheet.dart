import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';
import '../../../providers/tafseer_edition_provider.dart';
import '../../../providers/arabic_font_provider.dart';

/// Bottom sheet for displaying Tafseer content with improved formatting
class TafseerBottomSheet extends ConsumerWidget {
  final int surahId;
  final int ayahId;
  final String surahName;

  const TafseerBottomSheet({
    super.key,
    required this.surahId,
    required this.ayahId,
    required this.surahName,
  });

  static void show(BuildContext context, {
    required int surahId,
    required int ayahId,
    required String surahName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TafseerBottomSheet(
        surahId: surahId,
        ayahId: ayahId,
        surahName: surahName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafseerAsync = ref.watch(tafseerProvider((surahId: surahId, ayahId: ayahId)));
    final selectedEdition = ref.watch(selectedTafseerEditionProvider);
    final arabicFont = ref.watch(arabicFontProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30A14E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF40C463),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedEdition.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$surahName • Ayah $ayahId',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Copy button
                    IconButton(
                      onPressed: () {
                        final tafseer = tafseerAsync.valueOrNull;
                        if (tafseer != null) {
                          Clipboard.setData(ClipboardData(text: tafseer.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tafseer copied'),
                              backgroundColor: const Color(0xFF30A14E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.copy_outlined,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              
              // Content
              Expanded(
                child: tafseerAsync.when(
                  data: (tafseer) {
                    if (tafseer == null || tafseer.text.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: _buildFormattedTafseer(tafseer.text, arabicFont.fontFamily ?? 'Amiri'),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF40C463),
                      strokeWidth: 2,
                    ),
                  ),
                  error: (error, _) => _buildErrorState(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Formats tafseer text with proper Arabic/translation separation
  Widget _buildFormattedTafseer(String text, String arabicFontFamily) {
    // Split text into segments - Arabic and translation
    final segments = _parseText(text);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: segments.map((segment) {
        if (segment.isArabic) {
          // Arabic text - right aligned, larger font
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              segment.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 2.0,
                fontFamily: arabicFontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
          // Translation/explanation text
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              segment.text,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.85,
                letterSpacing: 0.2,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  /// Parse text to identify Arabic and non-Arabic segments
  List<_TextSegment> _parseText(String text) {
    final segments = <_TextSegment>[];
    
    // Pattern to match Arabic text (including diacritics)
    final arabicPattern = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s]+',
    );
    
    // Simple approach: split by sentences/paragraphs and detect Arabic
    final lines = text.split(RegExp(r'\n\s*\n'));
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      // Check if this line is predominantly Arabic
      final arabicMatches = arabicPattern.allMatches(trimmed);
      int arabicLength = 0;
      for (final match in arabicMatches) {
        arabicLength += match.end - match.start;
      }
      
      // If more than 60% Arabic characters, treat as Arabic
      final isArabic = arabicLength > trimmed.length * 0.6;
      
      if (isArabic) {
        segments.add(_TextSegment(text: trimmed, isArabic: true));
      } else {
        // For mixed text, try to extract and separate Arabic phrases
        _parseMixedText(trimmed, segments, arabicPattern);
      }
    }
    
    // If no segments created, just show as plain text
    if (segments.isEmpty) {
      segments.add(_TextSegment(text: text, isArabic: false));
    }
    
    return segments;
  }

  /// Parse mixed text that contains both Arabic and translation
  void _parseMixedText(String text, List<_TextSegment> segments, RegExp arabicPattern) {
    // Look for Arabic phrases embedded in the text
    final matches = arabicPattern.allMatches(text).toList();
    
    if (matches.isEmpty) {
      segments.add(_TextSegment(text: text, isArabic: false));
      return;
    }
    
    int lastEnd = 0;
    for (final match in matches) {
      // Add non-Arabic text before this match
      if (match.start > lastEnd) {
        final nonArabic = text.substring(lastEnd, match.start).trim();
        if (nonArabic.isNotEmpty) {
          segments.add(_TextSegment(text: nonArabic, isArabic: false));
        }
      }
      
      // Add Arabic text if it's significant (not just spaces/punctuation)
      final arabicText = match.group(0)?.trim() ?? '';
      if (arabicText.length > 3) { // Only add if meaningful Arabic text
        segments.add(_TextSegment(text: arabicText, isArabic: true));
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining non-Arabic text
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        segments.add(_TextSegment(text: remaining, isArabic: false));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[700],
              size: 56,
            ),
            const SizedBox(height: 20),
            Text(
              'Tafseer not available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different edition\nin Settings → Tafseer Edition',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.grey[700],
              size: 56,
            ),
            const SizedBox(height: 20),
            Text(
              'Could not load tafseer',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection\nand try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for text segments
class _TextSegment {
  final String text;
  final bool isArabic;

  _TextSegment({required this.text, required this.isArabic});
}
