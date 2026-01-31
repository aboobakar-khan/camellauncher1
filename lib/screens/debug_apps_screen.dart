import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import '../utils/app_filter_utils.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug screen to show all installed apps with package names
/// This helps identify apps that are not showing in the main list
class DebugAppsScreen extends ConsumerStatefulWidget {
  const DebugAppsScreen({super.key});

  @override
  ConsumerState<DebugAppsScreen> createState() => _DebugAppsScreenState();
}

class _DebugAppsScreenState extends ConsumerState<DebugAppsScreen> {
  List<AppInfo> _allApps = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllApps();
  }

  Future<void> _loadAllApps() async {
    setState(() => _isLoading = true);

    try {
      final apps = await AppFilterUtils.getAllAppsForDebug();
      setState(() {
        _allApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<AppInfo> get _displayedApps {
    if (_searchQuery.isEmpty) return _allApps;

    final query = _searchQuery.toLowerCase();
    return _allApps.where((app) {
      return app.name.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 1),
      ),
    );
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
          'Debug: All Apps (${_allApps.length})',
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
                hintText: 'Search by name or package...',
                hintStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _displayedApps.length,
                    itemBuilder: (context, index) {
                      final app = _displayedApps[index];
                      final isInWhitelist = AppFilterUtils.isInWhitelist(
                        app.packageName,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isInWhitelist
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.red.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            app.name,
                            style: TextStyle(
                              color: themeColor.color.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: app.packageName),
                              );
                              _copyToClipboard(app.packageName);
                            },
                            child: Text(
                              app.packageName,
                              style: TextStyle(
                                color: isInWhitelist
                                    ? Colors.green.withValues(alpha: 0.6)
                                    : Colors.red.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                          trailing: isInWhitelist
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green.withValues(alpha: 0.7),
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),

          // Footer with count
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: ${_allApps.length} apps | Displayed: ${_displayedApps.length} apps\nGreen = Whitelisted, Red = Filtered',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
