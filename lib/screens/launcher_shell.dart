import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/theme_provider.dart';
import 'home_clock_screen.dart';
import 'widget_dashboard_screen.dart';
import 'app_list_screen.dart';
import '../features/quran/screens/surah_list_screen.dart';
import '../features/hadith_dua/screens/hadith_dua_screen.dart';

/// Main launcher shell with swipeable pages
/// Layout: [Islamic Hub] ← [Dashboard] ← [HOME] → [App List]
class LauncherShell extends ConsumerStatefulWidget {
  const LauncherShell({super.key});

  @override
  ConsumerState<LauncherShell> createState() => _LauncherShellState();
}

class _LauncherShellState extends ConsumerState<LauncherShell>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;

  // Home is at index 2 (middle)
  static const int _homeIndex = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _homeIndex);
    _animController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallpaper = ref.watch(wallpaperProvider);

    // Block system back gesture for launcher
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            _buildBackground(wallpaper),

            // Edge gesture blockers - consume swipes at screen edges
            // Left edge blocker
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                onHorizontalDragStart: (_) {},
                onHorizontalDragUpdate: (_) {},
                onHorizontalDragEnd: (_) {},
                behavior: HitTestBehavior.translucent,
              ),
            ),
            // Right edge blocker
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                onHorizontalDragStart: (_) {},
                onHorizontalDragUpdate: (_) {},
                onHorizontalDragEnd: (_) {},
                behavior: HitTestBehavior.translucent,
              ),
            ),

            // Main content - 4 swipeable pages
            // [Islamic Hub] [Dashboard] [HOME] [Apps]
            //      0            1          2      3
            PageView(
              controller: _pageController,
              physics: const ClampingScrollPhysics(), // No bounce at edges
              children: const [
                // Swipe LEFT from home
                IslamicHubScreen(),       // Index 0 - Combined Quran + Hadith
                WidgetDashboardScreen(),  // Index 1
                
                // HOME (middle - starts here)
                HomeClockScreen(),        // Index 2
                
                // Swipe RIGHT from home
                AppListScreen(),          // Index 3
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(WallpaperType wallpaper) {
    if (wallpaper == WallpaperType.customImage) {
      final imagePath = ref.read(wallpaperProvider.notifier).customImagePath;
      if (imagePath != null && File(imagePath).existsSync()) {
        return Positioned.fill(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _getWallpaperGradient(wallpaper),
            ),
          );
        },
      ),
    );
  }

  LinearGradient _getWallpaperGradient(WallpaperType wallpaper) {
    switch (wallpaper) {
      case WallpaperType.black:
        return const LinearGradient(colors: [Colors.black, Colors.black]);
      case WallpaperType.darkGradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF0a0a0a), const Color(0xFF1a1a1a), _animController.value)!,
            const Color(0xFF000000),
            Color.lerp(const Color(0xFF0f0f0f), const Color(0xFF1a1a1a), _animController.value)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case WallpaperType.blueGradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF0d1b2a), const Color(0xFF1b263b), _animController.value)!,
            const Color(0xFF000000),
            Color.lerp(const Color(0xFF0f1f2f), const Color(0xFF1b263b), _animController.value)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case WallpaperType.purpleGradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF1a0a2e), const Color(0xFF16213e), _animController.value)!,
            const Color(0xFF000000),
            Color.lerp(const Color(0xFF0f0a1f), const Color(0xFF1a0a2e), _animController.value)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case WallpaperType.redGradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF2d0a0a), const Color(0xFF1a0a0a), _animController.value)!,
            const Color(0xFF000000),
            Color.lerp(const Color(0xFF1f0a0a), const Color(0xFF2d0a0a), _animController.value)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case WallpaperType.greenGradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF0a2d0a), const Color(0xFF0a1a0a), _animController.value)!,
            const Color(0xFF000000),
            Color.lerp(const Color(0xFF0a1f0a), const Color(0xFF0a2d0a), _animController.value)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case WallpaperType.customImage:
        return const LinearGradient(colors: [Colors.black, Colors.black]);
    }
  }
}

/// Islamic Hub - Combined Quran + Hadith/Dua with clean tabs
class IslamicHubScreen extends ConsumerStatefulWidget {
  const IslamicHubScreen({super.key});

  @override
  ConsumerState<IslamicHubScreen> createState() => _IslamicHubScreenState();
}

class _IslamicHubScreenState extends ConsumerState<IslamicHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with prominent tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  // Quran tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(0),
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final isSelected = _tabController.index == 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? themeColor.color.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? themeColor.color.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              'Quran',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Hadith tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final isSelected = _tabController.index == 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? themeColor.color.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? themeColor.color.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              'Hadith',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content - swipe disabled so main page navigation works
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe - tap to switch tabs
                children: const [
                  SurahListScreen(),
                  HadithDuaScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
