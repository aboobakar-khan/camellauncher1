import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';
import '../../../providers/tafseer_edition_provider.dart';

/// Bottom sheet for displaying Tafseer content
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

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
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
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30A14E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF40C463),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedEdition.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$surahName : Ayah $ayahId',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Color(0xFF333333), height: 1),
              
              // Content
              Expanded(
                child: tafseerAsync.when(
                  data: (tafseer) {
                    if (tafseer == null || tafseer.text.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey[600],
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tafseer not available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different edition in Settings',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        tafseer.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.8,
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF40C463),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load tafseer',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your internet connection',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
