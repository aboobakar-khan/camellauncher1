import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installed_app.dart';
import '../providers/favorite_apps_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/app_interrupt_provider.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/hidden_apps_provider.dart';
import '../services/app_settings_service.dart';
import '../widgets/app_interrupt_dialog.dart';
import 'settings_screen.dart';

/// App List Screen - Minimalist launcher
/// Text-only, stored in Hive, loaded in memory, instant filtering
class AppListScreen extends ConsumerStatefulWidget {
  const AppListScreen({super.key});

  @override
  ConsumerState<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends ConsumerState<AppListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes back to foreground, refresh the app list
    // This catches newly installed apps from Play Store
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchApp(String packageName) async {
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
      // Show interrupt dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AppInterruptDialog(interrupt: interrupt, onSuccess: () {}),
      );

      if (shouldProceed != true) {
        return; // User cancelled
      }
    }

    // Launch the app
    try {
      // Special handling for Google Pay - use native intent
      if (packageName.contains('paisa') || packageName.contains('googlepay')) {
        await AppSettingsService.launchGooglePay();
      } else if (packageName == 'net.one97.paytm') {
        // Special handling for Paytm - open app settings as workaround
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
            // App name header
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

                // Capture theme color before async operations
                final color = themeColor.color;

                // Hide the app in the hidden apps provider
                await ref
                    .read(hiddenAppsProvider.notifier)
                    .hideApp(app.packageName, app.appName);

                // Immediately remove from installed apps list using the proper notifier method
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

                // Show confirmation dialog
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

                          // Immediately remove the app from the list (instant feedback)
                          ref
                              .read(installedAppsProvider.notifier)
                              .removeApp(app.packageName);

                          // Trigger the uninstall dialog
                          await AppSettingsService.uninstallApp(
                            app.packageName,
                          );

                          // Verify uninstall in background by refreshing after delay
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

                // The uninstall is now triggered directly from the dialog button
                // No need for additional logic here
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
    // Get apps from memory - instant, no cache needed
    final allApps = ref.watch(installedAppsProvider);
    final installedAppsNotifier = ref.watch(installedAppsProvider.notifier);

    // Watch hidden apps to trigger rebuild when an app is hidden
    ref.watch(hiddenAppsProvider);

    // Filter in memory - instant performance
    final filteredApps = installedAppsNotifier.filterApps(_searchQuery);
    final isRefreshing = installedAppsNotifier.isRefreshing;

    // Theme color
    final themeColor = ref.watch(themeColorProvider);

    // Remove view insets (like navigation bar) globally for this screen
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.removeViewInsets(removeBottom: true),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              _buildSearchBar(themeColor),

              // App count indicator and settings button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
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

              // App list - always loaded from memory
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
                        // Performance optimizations
                        cacheExtent: 500,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return _buildAppItem(app, themeColor);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: themeColor.color.withValues(alpha: 0.9),
          fontSize: 16,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          hintText: 'Search apps...',
          hintStyle: TextStyle(
            color: themeColor.color.withValues(alpha: 0.3),
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    _searchController.clear();
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
      child: InkWell(
        onTap: () => _launchApp(app.packageName),
        onLongPress: () => _showAppOptions(context, app, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  app.appName,
                  style: TextStyle(
                    color: themeColor.color.withValues(alpha: 0.7),
                    fontSize: 18,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite
                      ? Colors.amber.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.3),
                  size: 22,
                ),
                onPressed: () async {
                  final success = await ref
                      .read(favoriteAppsProvider.notifier)
                      .toggleFavorite(app.packageName, app.appName);

                  if (!success && mounted) {
                    // Show message when limit is reached
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Maximum 7 favorite apps allowed',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  setState(() {}); // Force rebuild to update star icon
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
