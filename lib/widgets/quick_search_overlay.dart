import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import '../models/installed_app.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorite_apps_provider.dart';
import '../providers/app_interrupt_provider.dart';
import '../providers/focus_mode_provider.dart';
import '../widgets/app_interrupt_dialog.dart';

/// Quick Search Overlay - Samsung-style pull-down search
/// 
/// Features:
/// - Appears on swipe down from home
/// - INSTANT search using apps already in memory
/// - Auto-opens single match
/// - Text-only minimalist design (no icons)
class QuickSearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onDismiss;

  const QuickSearchOverlay({super.key, required this.onDismiss});

  @override
  ConsumerState<QuickSearchOverlay> createState() => _QuickSearchOverlayState();
}

class _QuickSearchOverlayState extends ConsumerState<QuickSearchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  String _searchQuery = '';
  bool _hasAutoLaunched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200), // Faster animation
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    
    // Auto-focus search instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        _hasAutoLaunched = false;
      });
      
      // Check for auto-launch
      _checkAutoLaunch();
    }
  }

  void _checkAutoLaunch() {
    if (_hasAutoLaunched || _searchQuery.isEmpty) return;
    
    final installedAppsNotifier = ref.read(installedAppsProvider.notifier);
    final filteredApps = installedAppsNotifier.filterApps(_searchQuery);
    
    // Auto-launch when exactly 1 result
    if (filteredApps.length == 1) {
      _hasAutoLaunched = true;
      HapticFeedback.lightImpact();
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _launchApp(filteredApps.first);
        }
      });
    }
  }

  Future<void> _launchApp(InstalledApp app) async {
    _searchFocus.unfocus();
    
    // Check focus mode
    final focusModeNotifier = ref.read(focusModeProvider.notifier);
    if (focusModeNotifier.isAppBlocked(app.packageName)) {
      final focusMode = ref.read(focusModeProvider);
      _showBlockedDialog(focusMode.blockMessage ?? 'Focus mode is active.');
      return;
    }

    // Check interrupt
    final interruptNotifier = ref.read(appInterruptProvider.notifier);
    final interrupt = interruptNotifier.getInterrupt(app.packageName);

    if (interrupt != null && interrupt.isEnabled) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AppInterruptDialog(interrupt: interrupt, onSuccess: () {}),
      );

      if (shouldProceed != true) return;
    }

    // Dismiss and launch
    widget.onDismiss();
    try {
      await InstalledApps.startApp(app.packageName);
    } catch (e) {
      // Silent fail
    }
  }

  void _showBlockedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.orange.shade400),
            const SizedBox(width: 12),
            const Text('Focus Mode', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _dismiss() {
    _searchFocus.unfocus();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    
    // Get apps directly from memory - INSTANT!
    final installedAppsNotifier = ref.watch(installedAppsProvider.notifier);
    final allApps = ref.watch(installedAppsProvider);
    final favorites = ref.watch(favoriteAppsProvider);
    
    // Filter apps instantly from memory
    final filteredApps = _searchQuery.isEmpty 
        ? <InstalledApp>[]
        : installedAppsNotifier.filterApps(_searchQuery).take(8).toList();
    
    // Get suggested apps (favorites)
    final favoritePackages = favorites.map((f) => f.packageName).toSet();
    final suggestedApps = allApps
        .where((app) => favoritePackages.contains(app.packageName))
        .take(6)
        .toList();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Tap to dismiss background
            GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
                  _dismiss();
                }
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.6 * _fadeAnimation.value),
              ),
            ),
            
            // Search panel
            SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: 'Search apps...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: themeColor.color.withValues(alpha: 0.7),
                                      ),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _onSearchChanged('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Results or suggestions (INSTANT!)
                                if (_searchQuery.isNotEmpty)
                                  _buildSearchResults(filteredApps, themeColor)
                                else
                                  _buildSuggestedApps(suggestedApps, themeColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Hint
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        'swipe up or tap outside to close',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 11,
                          letterSpacing: 1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(List<InstalledApp> apps, AppThemeColor themeColor) {
    if (apps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No apps found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESULTS',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 12),
        ...apps.map((app) => _buildAppTile(app, themeColor)),
      ],
    );
  }

  Widget _buildSuggestedApps(List<InstalledApp> apps, AppThemeColor themeColor) {
    if (apps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Type to search apps...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 13,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAVORITES',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 12),
        // Text-only list (no icons)
        ...apps.map((app) => _buildAppTile(app, themeColor)),
      ],
    );
  }

  Widget _buildAppTile(InstalledApp app, AppThemeColor themeColor) {
    return GestureDetector(
      onTap: () => _launchApp(app),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // Text only - NO icon!
            Expanded(
              child: Text(
                app.appName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none, // Remove yellow underline
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the quick search overlay
void showQuickSearchOverlay(BuildContext context) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => QuickSearchOverlay(
      onDismiss: () => entry.remove(),
    ),
  );
  
  Overlay.of(context).insert(entry);
}
