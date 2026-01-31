import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installed_app.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/theme_provider.dart';

class FocusModeSettingsScreen extends ConsumerStatefulWidget {
  const FocusModeSettingsScreen({super.key});

  @override
  ConsumerState<FocusModeSettingsScreen> createState() =>
      _FocusModeSettingsScreenState();
}

class _FocusModeSettingsScreenState
    extends ConsumerState<FocusModeSettingsScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final installedAppsNotifier = ref.watch(installedAppsProvider.notifier);
    final allApps = ref.watch(installedAppsProvider);
    final themeColor = ref.watch(themeColorProvider);

    // Filter in memory - instant performance
    final filteredApps = installedAppsNotifier.filterApps(_searchQuery);
    final isRefreshing = installedAppsNotifier.isRefreshing;

    final allowedApps = filteredApps.where((app) {
      return focusMode.allowedApps.contains(app.packageName);
    }).toList();
    final otherApps = filteredApps.where((app) {
      return !focusMode.allowedApps.contains(app.packageName);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text('Focus Mode')],
        ),
        actions: [
          // Focus mode toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(
                  focusMode.isEnabled ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: focusMode.isEnabled
                        ? Colors.green.shade400
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: focusMode.isEnabled,
                  onChanged: (_) {
                    ref.read(focusModeProvider.notifier).toggleFocusMode();
                  },
                  activeThumbColor: Colors.green.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          if (focusMode.isEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade900.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(Icons.lock_clock, color: Colors.green.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Focus mode active! Only selected apps are accessible.',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              style: TextStyle(color: themeColor.color.withValues(alpha: 0.9)),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.3),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Apps list
          Expanded(
            child: allApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white30),
                        const SizedBox(height: 16),
                        Text(
                          'Loading apps into memory...',
                          style: TextStyle(
                            color: themeColor.color.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (allowedApps.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Allowed in Focus Mode',
                          allowedApps.length,
                          Colors.green.shade400,
                          isRefreshing,
                        ),
                        ...allowedApps.map((app) => _buildAppItem(app, true)),
                      ],
                      if (otherApps.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Blocked in Focus Mode',
                          otherApps.length,
                          Colors.red.shade400,
                          isRefreshing,
                        ),
                        ...otherApps.map((app) => _buildAppItem(app, false)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    Color color,
    bool isRefreshing,
  ) {
    final focusMode = ref.watch(focusModeProvider);
    final isAllowedSection = title.contains('Allowed');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
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
          if (isAllowedSection) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: focusMode.canAddMoreApps()
                    ? Colors.blue.shade900.withValues(alpha: 0.3)
                    : Colors.orange.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focusMode.canAddMoreApps()
                      ? Colors.blue.shade400
                      : Colors.orange.shade400,
                ),
              ),
              child: Text(
                focusMode.canAddMoreApps()
                    ? '${focusMode.remainingSlots} slots left'
                    : 'Max 5 apps',
                style: TextStyle(
                  color: focusMode.canAddMoreApps()
                      ? Colors.blue.shade400
                      : Colors.orange.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppItem(InstalledApp app, bool isAllowed) {
    final focusMode = ref.watch(focusModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    final canAdd = focusMode.canAddMoreApps();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        app.appName,
        style: TextStyle(
          color: themeColor.color.withValues(alpha: 0.9),
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          isAllowed ? Icons.remove_circle : Icons.add_circle,
          color: isAllowed
              ? Colors.red.shade400
              : (canAdd ? Colors.green.shade400 : Colors.grey),
        ),
        onPressed: () {
          if (isAllowed) {
            ref
                .read(focusModeProvider.notifier)
                .removeAllowedApp(app.packageName);
          } else if (canAdd) {
            ref.read(focusModeProvider.notifier).addAllowedApp(app.packageName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Maximum 5 apps allowed in focus mode'),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}
