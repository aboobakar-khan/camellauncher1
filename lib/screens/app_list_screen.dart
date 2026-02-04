import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installed_app.dart';
import '../providers/favorite_apps_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/app_interrupt_provider.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/hidden_apps_provider.dart';
import '../providers/recent_apps_provider.dart';
import '../services/app_settings_service.dart';
import '../widgets/app_interrupt_dialog.dart';
import 'settings_screen.dart';

/// App List Screen - Minimalist launcher
/// Text-only, stored in Hive, loaded in memory, instant filtering
/// Smart search: auto-opens single match, case-insensitive
class AppListScreen extends ConsumerStatefulWidget {
  const AppListScreen({super.key});

  @override
  ConsumerState<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends ConsumerState<AppListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _hasAutoLaunched = false; // Prevent multiple auto-launches

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text;
    if (newQuery != _searchQuery) {
      setState(() {
        _searchQuery = newQuery;
        _hasAutoLaunched = false; // Reset on new search
      });
      
      // Auto-open if single match
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
      
      // Small delay to show the match before launching
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _launchApp(filteredApps.first.packageName);
          // Clear search after launch
          _searchController.clear();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshAppList();
    }
  }

  Future<void> _refreshAppList() async {
    final hiddenApps = ref.read(hiddenAppsProvider);
    await ref
        .read(installedAppsProvider.notifier)
        .refreshApps(hiddenApps: hiddenApps);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _launchApp(String packageName) async {
    // Unfocus search when launching
    _searchFocusNode.unfocus();
    
    // Check if focus mode is blocking this app
    final focusModeNotifier = ref.read(focusModeProvider.notifier);
    if (focusModeNotifier.isAppBlocked(packageName)) {
      final focusMode = ref.read(focusModeProvider);
      _showFocusModeBlockDialog(
        focusMode.blockMessage ?? 'Focus mode is active. This app is blocked.',
      );
      return;
    }

    // Check if app has an interrupt configured
    final interruptNotifier = ref.read(appInterruptProvider.notifier);
    final interrupt = interruptNotifier.getInterrupt(packageName);

    if (interrupt != null && interrupt.isEnabled) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AppInterruptDialog(interrupt: interrupt, onSuccess: () {}),
      );

      if (shouldProceed != true) {
        return;
      }
    }

    // Track as recent app
    ref.read(recentAppsProvider.notifier).addRecent(packageName);

    // Launch the app
    try {
      if (packageName.contains('paisa') || packageName.contains('googlepay')) {
        await AppSettingsService.launchGooglePay();
      } else if (packageName == 'net.one97.paytm') {
        await InstalledApps.startApp(packageName);
      } else {
        await InstalledApps.startApp(packageName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open app: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAppOptions(BuildContext context, InstalledApp app, WidgetRef ref) {
    final themeColor = ref.read(themeColorProvider);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                app.appName,
                style: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Divider(color: Colors.white12),

            // Hide app option
            ListTile(
              leading: Icon(
                Icons.visibility_off,
                color: themeColor.color.withValues(alpha: 0.7),
              ),
              title: Text(
                'Hide this app',
                style: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.9),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final color = themeColor.color;

                await ref
                    .read(hiddenAppsProvider.notifier)
                    .hideApp(app.packageName, app.appName);

                ref
                    .read(installedAppsProvider.notifier)
                    .removeApp(app.packageName);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${app.appName} hidden. Go to Settings > Hidden Apps to unhide.',
                        style: TextStyle(color: color.withValues(alpha: 0.9)),
                      ),
                      backgroundColor: Colors.black.withValues(alpha: 0.9),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),

            // Uninstall app option
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400.withValues(alpha: 0.8),
              ),
              title: Text(
                'Uninstall app',
                style: TextStyle(
                  color: Colors.red.shade400.withValues(alpha: 0.9),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);

                await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    insetPadding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16 + MediaQuery.of(context).padding.bottom,
                    ),
                    title: Text(
                      'Uninstall ${app.appName}?',
                      style: const TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This will uninstall the app from your device.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(false);

                          ref
                              .read(installedAppsProvider.notifier)
                              .removeApp(app.packageName);

                          await AppSettingsService.uninstallApp(
                            app.packageName,
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              _refreshAppList();
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                        ),
                        child: const Text('Uninstall'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFocusModeBlockDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.orange.shade400),
            const SizedBox(width: 12),
            const Text(
              'Focus Mode Active',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allApps = ref.watch(installedAppsProvider);
    final installedAppsNotifier = ref.watch(installedAppsProvider.notifier);
    ref.watch(hiddenAppsProvider);

    final filteredApps = installedAppsNotifier.filterApps(_searchQuery);
    final isRefreshing = installedAppsNotifier.isRefreshing;
    final themeColor = ref.watch(themeColorProvider);

    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.removeViewInsets(removeBottom: true),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: SafeArea(
          child: Column(
            children: [
              // Header with app count and settings
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${filteredApps.length} apps',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            letterSpacing: 1.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (isRefreshing) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // App list
              Expanded(
                child: allApps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white30,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Wait a moment...',
                              style: TextStyle(
                                color: themeColor.color.withValues(alpha: 0.5),
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          'No apps found',
                          style: TextStyle(
                            color: themeColor.color.withValues(alpha: 0.3),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredApps.length,
                        cacheExtent: 500,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return _buildAppItem(app, themeColor);
                        },
                      ),
              ),

              // Search bar at BOTTOM
              _buildBottomSearchBar(themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar(AppThemeColor themeColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(
          color: themeColor.color.withValues(alpha: 0.9),
          fontSize: 16,
          letterSpacing: 1.0,
        ),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Type to search apps...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: themeColor.color.withValues(alpha: 0.3)),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAppItem(InstalledApp app, AppThemeColor themeColor) {
    final isFavorite = ref
        .watch(favoriteAppsProvider.notifier)
        .isFavorite(app.packageName);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _launchApp(app.packageName),
        onLongPress: () => _showAppOptions(context, app, ref),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              // Text only - no icons
              Expanded(
                child: Text(
                  app.appName,
                  style: TextStyle(
                    color: themeColor.color.withValues(alpha: 0.7),
                    fontSize: 17,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none, // Explicitly no underline
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Favorite star (subtle)
              if (isFavorite)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.star,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
