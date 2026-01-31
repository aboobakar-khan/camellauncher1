import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/hidden_apps_provider.dart';
import '../models/focus_mode.dart';
import '../utils/app_filter_utils.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// Focus Mode Screen - Minimal screen shown when focus mode is active
/// Only displays allowed apps in a clean, distraction-free layout
class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> {
  List<AppInfo> _allowedApps = [];
  bool _isLoading = true;
  late Timer _timer;
  String _currentTime = '';

  // Cache for faster loading
  static Map<String, AppInfo>? _appsCache;
  static DateTime? _lastCacheUpdate;
  static const _cacheValidityDuration = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _loadAllowedApps();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  Future<void> _loadAllowedApps() async {
    try {
      final focusMode = ref.read(focusModeProvider);
      final now = DateTime.now();
      final cacheExpired =
          _lastCacheUpdate == null ||
          now.difference(_lastCacheUpdate!) > _cacheValidityDuration;

      // Try to use cache first for instant display
      if (_appsCache != null && !cacheExpired) {
        final cached = focusMode.allowedApps
            .where((pkg) => _appsCache!.containsKey(pkg))
            .map((pkg) => _appsCache![pkg]!)
            .toList();

        if (cached.length == focusMode.allowedApps.length) {
          setState(() {
            _allowedApps = cached;
            _isLoading = false;
          });
          return;
        }
      }

      // Load all apps and filter
      final hiddenApps = ref.read(hiddenAppsProvider);
      final allApps = await AppFilterUtils.getFilteredAppsAlternative(
        hiddenApps: hiddenApps,
      );

      // Update cache
      _appsCache = {for (var app in allApps) app.packageName: app};
      _lastCacheUpdate = now;

      setState(() {
        _allowedApps = allApps
            .where((app) => focusMode.allowedApps.contains(app.packageName))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot open app: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - make entire content scrollable
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Header with time and focus indicator
                    _buildHeader(focusMode),

                    // Allowed apps section
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          )
                        : _allowedApps.isEmpty
                        ? _buildEmptyState()
                        : _buildAppsList(),
                  ],
                ),
              ),
            ),

            // Exit button positioned at top left
            Positioned(top: 16, left: 16, child: _buildExitButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FocusModeSettings focusMode) {
    final startTime = focusMode.startTime ?? DateTime.now();
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Focus mode indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock, color: Colors.green.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                'FOCUS MODE',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Large clock
          Text(
            _currentTime,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 72,
              fontWeight: FontWeight.w200,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),

          // Focus duration
          Text(
            hours > 0 ? '${hours}h ${minutes}m focused' : '${minutes}m focused',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ALLOWED APPS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._allowedApps.map((app) => _buildAppItem(app)),
        ],
      ),
    );
  }

  Widget _buildAppItem(AppInfo app) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextButton(
        onPressed: () => _launchApp(app.packageName),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          app.name,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 18,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'No apps selected',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add apps in Focus Mode settings\nto access them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    return IconButton(
      onPressed: () {
        ref.read(focusModeProvider.notifier).toggleFocusMode();
      },
      icon: Icon(
        Icons.close,
        color: Colors.white.withValues(alpha: 0.6),
        size: 24,
      ),
      tooltip: 'Exit Focus Mode',
    );
  }
}
