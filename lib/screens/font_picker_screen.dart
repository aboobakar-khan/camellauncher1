import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/font_provider.dart';

/// Font Picker Screen
class FontPickerScreen extends ConsumerWidget {
  const FontPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(fontProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Font list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: AppFonts.all.length,
                itemBuilder: (context, index) {
                  final font = AppFonts.all[index];
                  final isSelected = font.name == currentFont.name;

                  return _buildFontOption(context, ref, font, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'FONT STYLE',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontOption(
    BuildContext context,
    WidgetRef ref,
    AppFont font,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(fontProvider.notifier).setFont(font);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font name
                  Text(
                    font.name,
                    style: TextStyle(
                      fontFamily: font.fontFamily,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      letterSpacing: 0.5,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Preview text
                  Text(
                    'The quick brown fox jumps',
                    style: TextStyle(
                      fontFamily: font.fontFamily,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
