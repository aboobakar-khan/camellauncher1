import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/hidden_apps_provider.dart';
import '../providers/tasbih_provider.dart';
import '../models/focus_mode.dart';
import '../utils/app_filter_utils.dart';
import '../features/quran/screens/surah_list_screen.dart';
import 'package:intl/intl.dart';

/// Focus Mode Screen - Minimalist design
/// 
/// Blocks swipe navigation and provides distraction-free environment
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
  int _quickTasbihCount = 0;

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
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  Future<void> _loadAllowedApps() async {
    try {
      final focusMode = ref.read(focusModeProvider);
      final hiddenApps = ref.read(hiddenAppsProvider);
      final allApps = await AppFilterUtils.getFilteredAppsAlternative(
        hiddenApps: hiddenApps,
      );

      if (mounted) {
        setState(() {
          _allowedApps = allApps
              .where((app) => focusMode.allowedApps.contains(app.packageName))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
    } catch (e) {
      // Silent fail
    }
  }

  void _openQuran() {
    // Push with full screen modal to avoid overlap issues
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const _FocusModeQuranWrapper(),
      ),
    );
  }

  void _showExitSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _MinimalExitSheet(
        focusMode: ref.read(focusModeProvider),
        onExit: () {
          ref.read(focusModeProvider.notifier).toggleFocusMode();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _incrementTasbih() {
    HapticFeedback.lightImpact();
    setState(() => _quickTasbihCount++);
    ref.read(tasbihProvider.notifier).increment();
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final startTime = focusMode.startTime ?? DateTime.now();
    final duration = DateTime.now().difference(startTime);
    
    // Block back gestures and swipes
    return PopScope(
      canPop: false, // Prevent back button/gesture
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitSheet(); // Show exit confirmation instead
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            // Tap anywhere to count tasbih
            onTap: _incrementTasbih,
            // Block horizontal swipes
            onHorizontalDragEnd: (_) {}, // Consume swipe gestures
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Main content - vertically centered
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Time - Large, calm, central focus point
                      Text(
                        _currentTime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 72,
                          fontWeight: FontWeight.w100,
                          letterSpacing: -4,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Duration - Subtle, non-intrusive
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const Spacer(flex: 1),
                      
                      // Tasbih counter
                      Column(
                        children: [
                          Text(
                            '$_quickTasbihCount',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 100,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                          Text(
                            'tasbih count',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.15),
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                
                // Exit button - Top left, very subtle
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _showExitSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                // Quran access - Top right, subtle
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _openQuran,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                // Allowed apps - Bottom, minimal
                if (!_isLoading && _allowedApps.isNotEmpty)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: _buildAllowedApps(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m focused';
    }
    return '${minutes}m focused';
  }

  Widget _buildAllowedApps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _allowedApps.take(5).map((app) {
        return GestureDetector(
          onTap: () => _launchApp(app.packageName),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              app.name.substring(0, app.name.length > 8 ? 8 : app.name.length),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Quran wrapper for Focus Mode - prevents navigation issues
class _FocusModeQuranWrapper extends StatelessWidget {
  const _FocusModeQuranWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quran',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: const SurahListScreen(isEmbedded: true),
    );
  }
}

/// Minimal Exit Sheet - Uses psychology of commitment
class _MinimalExitSheet extends StatefulWidget {
  final FocusModeSettings focusMode;
  final VoidCallback onExit;

  const _MinimalExitSheet({
    required this.focusMode,
    required this.onExit,
  });

  @override
  State<_MinimalExitSheet> createState() => _MinimalExitSheetState();
}

class _MinimalExitSheetState extends State<_MinimalExitSheet> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _canExit = false;

  // Simple, non-preachy reminders
  static const List<String> _reminders = [
    'Patience is half of faith.',
    'A moment of patience in anger saves a thousand moments of regret.',
    'The strong is not the one who overcomes people, but the one who controls himself.',
    'Verily, with hardship comes ease.',
  ];

  late String _reminder;

  @override
  void initState() {
    super.initState();
    _reminder = _reminders[DateTime.now().second % _reminders.length];
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canExit = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reminder - subtle, not preachy
            Text(
              _reminder,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Countdown or button
            if (!_canExit)
              // Countdown - simple number
              Text(
                '$_secondsRemaining',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 48,
                  fontWeight: FontWeight.w100,
                ),
              )
            else
              // Exit button - subdued, not alarming
              GestureDetector(
                onTap: widget.onExit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'end session',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Continue button - more prominent than exit
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'continue',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
