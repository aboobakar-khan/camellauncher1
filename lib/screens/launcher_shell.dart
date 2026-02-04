import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/theme_provider.dart';
import '../services/offline_content_manager.dart';
import 'home_clock_screen.dart';
import 'widget_dashboard_screen.dart';
import 'app_list_screen.dart';
import '../features/quran/screens/surah_list_screen.dart';
import '../features/hadith_dua/screens/minimalist_hadith_screen.dart';
import '../features/hadith_dua/screens/minimalist_dua_screen.dart';

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
  
  // Gesture tracking for smooth Samsung-like navigation
  double _dragStartX = 0;
  double _dragStartPage = 0;
  bool _isDragging = false;
  bool _isHorizontalDrag = false;
  bool _gestureDecided = false;
  
  // Thresholds
  static const double _decisionThreshold = 12.0; // Quick decision
  static const double _horizontalBias = 1.3; // Balanced bias (45° = equal)

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
  
  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _dragStartPage = _pageController.page ?? _homeIndex.toDouble();
    _isDragging = true;
    _isHorizontalDrag = false;
    _gestureDecided = false;
  }
  
  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final dx = details.globalPosition.dx - _dragStartX;
    final dy = (details.globalPosition.dy - details.localPosition.dy).abs();
    
    // Decide direction once we've moved enough
    if (!_gestureDecided) {
      final absDx = dx.abs();
      final absDy = details.delta.dy.abs() * 3; // Accumulate vertical movement
      
      if (absDx > _decisionThreshold || absDy > _decisionThreshold) {
        // Check if this is a horizontal swipe
        _isHorizontalDrag = absDx > absDy * _horizontalBias;
        _gestureDecided = true;
        
        if (!_isHorizontalDrag) {
          // Not horizontal, stop tracking
          _isDragging = false;
          return;
        }
      } else {
        return; // Wait for more movement
      }
    }
    
    // Smooth 1:1 finger tracking
    if (_isHorizontalDrag) {
      final screenWidth = MediaQuery.of(context).size.width;
      final pageDelta = -dx / screenWidth;
      final newPage = (_dragStartPage + pageDelta).clamp(0.0, 3.0);
      
      // Direct jump for smooth tracking
      _pageController.jumpTo(newPage * screenWidth);
    }
  }
  
  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || !_isHorizontalDrag) {
      _isDragging = false;
      return;
    }
    
    final velocity = details.velocity.pixelsPerSecond.dx;
    final currentPage = _pageController.page ?? _homeIndex.toDouble();
    int targetPage;
    
    // Velocity-based page switching
    if (velocity.abs() > 500) {
      // Fast swipe - go to next/prev page
      if (velocity < 0) {
        targetPage = currentPage.ceil().clamp(0, 3);
      } else {
        targetPage = currentPage.floor().clamp(0, 3);
      }
    } else if (velocity.abs() > 200) {
      // Medium swipe - consider current position
      final fraction = currentPage - currentPage.floor();
      if (velocity < 0 && fraction > 0.2) {
        targetPage = currentPage.ceil().clamp(0, 3);
      } else if (velocity > 0 && fraction < 0.8) {
        targetPage = currentPage.floor().clamp(0, 3);
      } else {
        targetPage = currentPage.round().clamp(0, 3);
      }
    } else {
      // Slow/no velocity - snap to nearest
      targetPage = currentPage.round().clamp(0, 3);
    }
    
    // Smooth animation to target
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final wallpaper = ref.watch(wallpaperProvider);
    
    // Initialize offline content manager for automatic background downloads
    ref.read(offlineContentProvider);

    // Block system back gesture for launcher
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            _buildBackground(wallpaper),

            // Edge gesture blockers - consume swipes at screen edges
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

            // Custom gesture handler for smooth Samsung-like navigation
            GestureDetector(
              onPanStart: _onDragStart,
              onPanUpdate: _onDragUpdate,
              onPanEnd: _onDragEnd,
              behavior: HitTestBehavior.translucent,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  IslamicHubScreen(),       // Index 0
                  WidgetDashboardScreen(),  // Index 1
                  HomeClockScreen(),        // Index 2 (HOME)
                  AppListScreen(),          // Index 3
                ],
              ),
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

/// Islamic Hub - Quran, Hadith, Dua with clean tabs
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
    _tabController = TabController(length: 3, vsync: this);
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
            // Header with 3 tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Quran tab
                  _buildTabButton(0, 'Quran', themeColor.color),
                  const SizedBox(width: 8),
                  // Hadith tab
                  _buildTabButton(1, 'Hadith', themeColor.color),
                  const SizedBox(width: 8),
                  // Dua tab
                  _buildTabButton(2, 'Dua', themeColor.color),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SurahListScreen(),
                  MinimalistHadithScreen(),
                  MinimalistDuaScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, Color themeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final isSelected = _tabController.index == index;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? themeColor.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected 
                      ? themeColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
