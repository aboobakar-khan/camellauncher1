import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../providers/hidden_apps_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/favorite_apps_provider.dart';
import '../utils/app_filter_utils.dart';

/// Quick Search Overlay - Samsung-style pull-down search
/// 
/// Features:
/// - Appears on swipe down from home
/// - Search bar + suggested/favorite apps
/// - Minimalist, blurred background
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
  
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  List<AppInfo> _suggestedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
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
    _loadApps();
    
    // Auto-focus search
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

  Future<void> _loadApps() async {
    final hiddenApps = ref.read(hiddenAppsProvider);
    final favorites = ref.read(favoriteAppsProvider);
    
    try {
      final allApps = await AppFilterUtils.getFilteredAppsAlternative(
        hiddenApps: hiddenApps,
      );
      
      // Get suggested apps (favorites first, then by name)
      final favoritePackages = favorites.map((f) => f.packageName).toSet();
      final suggested = allApps
          .where((app) => favoritePackages.contains(app.packageName))
          .take(6)
          .toList();
      
      // If not enough favorites, add some common apps
      if (suggested.length < 6) {
        final remaining = allApps
            .where((app) => !favoritePackages.contains(app.packageName))
            .take(6 - suggested.length);
        suggested.addAll(remaining);
      }
      
      if (mounted) {
        setState(() {
          _allApps = allApps;
          _suggestedApps = suggested;
          _filteredApps = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterApps(String query) {
    if (query.isEmpty) {
      setState(() => _filteredApps = []);
      return;
    }
    
    setState(() {
      _filteredApps = _allApps.where((app) {
        return app.name.toLowerCase().contains(query.toLowerCase());
      }).take(8).toList();
    });
  }

  Future<void> _launchApp(AppInfo app) async {
    HapticFeedback.lightImpact();
    widget.onDismiss();
    try {
      await InstalledApps.startApp(app.packageName);
    } catch (e) {
      // Silent fail
    }
  }

  void _dismiss() {
    _searchFocus.unfocus();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Tap to dismiss background
            GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                // Swipe up to dismiss
                if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
                  _dismiss();
                }
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.6 * _fadeAnimation.value),
              ),
            ),
            
            // Search panel - slides from top
            SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    // Search container
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
                                                _filterApps('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: _filterApps,
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Results or suggestions
                                if (_isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white24,
                                    ),
                                  )
                                else if (_searchController.text.isNotEmpty)
                                  _buildSearchResults(themeColor)
                                else
                                  _buildSuggestedApps(themeColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Hint at bottom
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        'swipe up or tap outside to close',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 11,
                          letterSpacing: 1,
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

  Widget _buildSearchResults(AppThemeColor themeColor) {
    if (_filteredApps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No apps found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
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
          ),
        ),
        const SizedBox(height: 12),
        ..._filteredApps.map((app) => _buildAppTile(app, themeColor)),
      ],
    );
  }

  Widget _buildSuggestedApps(AppThemeColor themeColor) {
    if (_suggestedApps.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUGGESTED',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _suggestedApps.map((app) {
            return GestureDetector(
              onTap: () => _launchApp(app),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: app.icon != null
                          ? Image.memory(app.icon!, fit: BoxFit.cover)
                          : Icon(
                              Icons.android,
                              color: themeColor.color,
                              size: 26,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 56,
                    child: Text(
                      app.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppTile(AppInfo app, AppThemeColor themeColor) {
    return GestureDetector(
      onTap: () => _launchApp(app),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: app.icon != null
                    ? Image.memory(app.icon!, fit: BoxFit.cover)
                    : Icon(
                        Icons.android,
                        color: themeColor.color,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                app.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 15,
                ),
              ),
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
