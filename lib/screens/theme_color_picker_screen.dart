import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// Theme Color Picker Screen
class ThemeColorPickerScreen extends ConsumerWidget {
  const ThemeColorPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Color grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: ThemeColors.all.length,
                itemBuilder: (context, index) {
                  final theme = ThemeColors.all[index];
                  final isSelected = theme.name == currentTheme.name;

                  return _buildColorOption(context, ref, theme, isSelected);
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
            'THEME COLOR',
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

  Widget _buildColorOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeColor theme,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(themeColorProvider.notifier).setThemeColor(theme);
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Color preview
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    theme.color.withValues(alpha: 0.3),
                    theme.accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Color name
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      letterSpacing: 1,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
