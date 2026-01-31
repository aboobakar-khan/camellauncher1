import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import '../providers/hidden_apps_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_filter_utils.dart';

/// Screen to manage hidden apps
/// Shows what was filtered out and allows users to:
/// - Unhide apps that were mistakenly filtered
/// - Hide apps they don't want to see
class HiddenAppsScreen extends ConsumerStatefulWidget {
  const HiddenAppsScreen({super.key});

  @override
  ConsumerState<HiddenAppsScreen> createState() => _HiddenAppsScreenState();
}

class _HiddenAppsScreenState extends ConsumerState<HiddenAppsScreen> {
  List<AppInfo> _filteredOutApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isProcessing = false; // Prevent simultaneous taps

  @override
  void initState() {
    super.initState();
    _loadFilteredApps();
  }

  Future<void> _loadFilteredApps() async {
    setState(() => _isLoading = true);

    try {
      final hiddenApps = ref.read(hiddenAppsProvider);
      final apps = await AppFilterUtils.getFilteredOutApps(
        hiddenApps: hiddenApps,
      );

      setState(() {
        _filteredOutApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Remove an app from the visible list without reloading
  void _removeAppFromList(String packageName) {
    setState(() {
      _filteredOutApps.removeWhere((app) => app.packageName == packageName);
    });
  }

  List<AppInfo> get _displayedApps {
    if (_searchQuery.isEmpty) return _filteredOutApps;

    final query = _searchQuery.toLowerCase();
    return _filteredOutApps.where((app) {
      return app.name.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hidden Apps',
          style: TextStyle(
            color: themeColor.color.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeColor.color.withValues(alpha: 0.7),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                color: themeColor.color.withValues(alpha: 0.9),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search hidden apps...',
                hintStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: themeColor.color.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: themeColor.color.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // Info message
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Text(
              'Tap to unhide.',
              style: TextStyle(
                color: themeColor.color.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),

          // App list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeColor.color.withValues(alpha: 0.5),
                    ),
                  )
                : _displayedApps.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No hidden apps found'
                          : 'No apps match your search',
                      style: TextStyle(
                        color: themeColor.color.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedApps.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final app = _displayedApps[index];
                      final hiddenApps = ref.watch(hiddenAppsProvider);
                      final isUnhidden = hiddenApps.any(
                        (hidden) =>
                            hidden.packageName == app.packageName &&
                            !hidden.isHiddenByUser,
                      );

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        title: Text(
                          app.name,
                          style: TextStyle(
                            color: themeColor.color.withValues(alpha: 0.9),
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: TextStyle(
                            color: themeColor.color.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                        trailing: isUnhidden
                            ? Icon(
                                Icons.visibility,
                                color: themeColor.color.withValues(alpha: 0.7),
                                size: 20,
                              )
                            : Icon(
                                Icons.visibility_off,
                                color: themeColor.color.withValues(alpha: 0.3),
                                size: 20,
                              ),
                        onTap: () async {
                          // Prevent simultaneous taps
                          if (_isProcessing) return;
                          _isProcessing = true;

                          try {
                            // Capture theme color before async operations
                            final color = themeColor.color;
                            final appName = app.name;
                            final packageName = app.packageName;

                            if (isUnhidden) {
                              // Remove from override list (go back to filtered)
                              await ref
                                  .read(hiddenAppsProvider.notifier)
                                  .removeFromList(packageName);

                              // Immediately add back to visible list
                              setState(() {
                                _filteredOutApps.add(app);
                              });
                            } else {
                              // Unhide (override filter) - instantly remove from display
                              await ref
                                  .read(hiddenAppsProvider.notifier)
                                  .unhideApp(packageName, appName);

                              // Immediately remove from the visible list
                              _removeAppFromList(packageName);
                            }

                            // Update installed apps list in background
                            final updatedHiddenApps = ref.read(
                              hiddenAppsProvider,
                            );
                            ref
                                .read(installedAppsProvider.notifier)
                                .refreshApps(hiddenApps: updatedHiddenApps);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isUnhidden
                                        ? '$appName will be hidden again'
                                        : '$appName will now appear in app list',
                                    style: TextStyle(
                                      color: color.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.9,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } finally {
                            _isProcessing = false;
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
