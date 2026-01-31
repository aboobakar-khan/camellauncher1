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

    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(wallpaper),

          // Main content - 4 swipeable pages
          // [Islamic Hub] [Dashboard] [HOME] [Apps]
          //      0            1          2      3
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    '☪',
                    style: TextStyle(
                      fontSize: 28,
                      color: themeColor.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Islamic',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: themeColor.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: themeColor.color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: themeColor.color,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Quran'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.format_quote_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Hadith & Dua'),
                      ],
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
