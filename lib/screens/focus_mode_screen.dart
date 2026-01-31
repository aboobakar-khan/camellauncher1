import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../providers/focus_mode_provider.dart';
import '../providers/hidden_apps_provider.dart';
import '../providers/tasbih_provider.dart';
import '../providers/theme_provider.dart';
import '../models/focus_mode.dart';
import '../utils/app_filter_utils.dart';
import '../features/quran/providers/quran_provider.dart';
import '../features/quran/screens/surah_list_screen.dart';
import '../features/hadith_dua/providers/hadith_dua_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// Focus Mode Screen - Enhanced with Islamic features and exit friction
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

      final hiddenApps = ref.read(hiddenAppsProvider);
      final allApps = await AppFilterUtils.getFilteredAppsAlternative(
        hiddenApps: hiddenApps,
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open app: $e')),
        );
      }
    }
  }

  void _showExitConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _ExitConfirmationSheet(
        onConfirm: () {
          ref.read(focusModeProvider.notifier).toggleFocusMode();
          Navigator.pop(context); // Close bottom sheet
          Navigator.pop(context); // Exit focus mode screen
        },
        focusMode: ref.read(focusModeProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header with time and focus indicator
                  _buildHeader(focusMode),

                  // Islamic Features Section
                  _buildIslamicSection(themeColor),

                  // Tasbih Counter Grid
                  _buildTasbihGrid(themeColor),

                  // Allowed apps section
                  if (!_isLoading && _allowedApps.isNotEmpty)
                    _buildAppsList(),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),

            // Exit button positioned at top left
            Positioned(
              top: 16,
              left: 16,
              child: _buildExitButton(),
            ),
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
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
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
          const SizedBox(height: 20),

          // Large clock
          Text(
            _currentTime,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 64,
              fontWeight: FontWeight.w200,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),

          // Focus duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hours > 0 ? '${hours}h ${minutes}m focused' : '${minutes}m focused',
              style: TextStyle(
                color: Colors.green.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicSection(AppThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Daily Verse Card
          _buildVerseCard(themeColor),
          
          const SizedBox(height: 12),
          
          // Daily Hadith Card
          _buildHadithCard(themeColor),
          
          const SizedBox(height: 12),
          
          // Quran Access Button
          _buildQuranAccessButton(themeColor),
        ],
      ),
    );
  }

  Widget _buildVerseCard(AppThemeColor themeColor) {
    final verseAsync = ref.watch(randomVerseProvider);
    
    return verseAsync.when(
      data: (verse) {
        if (verse == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF40C463).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: themeColor.color, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Verse',
                    style: TextStyle(
                      color: themeColor.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref.invalidate(randomVerseProvider),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verse['arabic'] as String,
                textAlign: TextAlign.right,
                textDirection: ui.TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.8,
                ),
              ),
              if (verse['translation'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  verse['translation'] as String,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHadithCard(AppThemeColor themeColor) {
    final hadithAsync = ref.watch(refreshableDailyHadithProvider);
    
    return hadithAsync.when(
      data: (hadith) {
        if (hadith == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Hadith',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    hadith.collection,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hadith.text.length > 150 
                    ? '${hadith.text.substring(0, 150)}...'
                    : hadith.text,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuranAccessButton(AppThemeColor themeColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SurahListScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColor.color.withValues(alpha: 0.15),
              themeColor.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeColor.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeColor.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                color: themeColor.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Read Quran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Continue your spiritual journey',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: themeColor.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbihGrid(AppThemeColor themeColor) {
    // Watch to trigger rebuilds
    ref.watch(tasbihProvider);
    
    // Show first 4 dhikr options as quick counters
    final quickDhikrs = Dhikr.presets.take(4).toList();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple.shade300, size: 16),
              const SizedBox(width: 8),
              Text(
                'QUICK TASBIH',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: quickDhikrs.length,
            itemBuilder: (context, index) {
              final dhikr = quickDhikrs[index];
              final count = ref.read(tasbihProvider.notifier).getCountForDhikr(index);
              final isComplete = count >= dhikr.defaultTarget;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Select this dhikr and increment
                  ref.read(tasbihProvider.notifier).selectDhikr(index);
                  ref.read(tasbihProvider.notifier).increment();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isComplete 
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isComplete
                          ? Colors.green.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dhikr.transliteration,
                        style: TextStyle(
                          color: isComplete ? Colors.green.shade400 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$count / ${dhikr.defaultTarget}',
                        style: TextStyle(
                          color: isComplete 
                              ? Colors.green.shade400 
                              : Colors.grey[500],
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (isComplete)
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _allowedApps.map((app) => GestureDetector(
              onTap: () => _launchApp(app.packageName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  app.name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return GestureDetector(
      onTap: _showExitConfirmation,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.close,
          color: Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
    );
  }
}

/// Exit Confirmation Sheet with 30-second wait and Islamic reminder
class _ExitConfirmationSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final FocusModeSettings focusMode;

  const _ExitConfirmationSheet({
    required this.onConfirm,
    required this.focusMode,
  });

  @override
  State<_ExitConfirmationSheet> createState() => _ExitConfirmationSheetState();
}

class _ExitConfirmationSheetState extends State<_ExitConfirmationSheet> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _canExit = false;

  // Islamic reminders about patience and perseverance
  static const List<String> _islamicReminders = [
    '"Indeed, Allah is with the patient."\n— Quran 2:153',
    '"So be patient. Indeed, the promise of Allah is truth."\n— Quran 30:60',
    '"And seek help through patience and prayer."\n— Quran 2:45',
    '"The strong believer is better than the weak believer."\n— Hadith (Muslim)',
    '"Whoever persists in patience, Allah will make him patient."\n— Hadith (Bukhari)',
    '"Take benefit of five before five: your youth before old age, your health before sickness..."\n— Hadith',
  ];

  late String _selectedReminder;

  @override
  void initState() {
    super.initState();
    _selectedReminder = _islamicReminders[DateTime.now().second % _islamicReminders.length];
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

  String _getFocusedDuration() {
    final startTime = widget.focusMode.startTime ?? DateTime.now();
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'End Focus Mode?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Duration info
          Text(
            'You\'ve been focused for ${_getFocusedDuration()}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Islamic reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedReminder,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber.shade100,
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Countdown or Exit button
          if (!_canExit) ...[
            // Countdown timer
            Column(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _secondsRemaining / 30,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation(Colors.red),
                      ),
                      Text(
                        '$_secondsRemaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wait to unlock exit',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Exit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'End Focus Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _canExit ? 'Keep Focusing' : 'Cancel',
              style: TextStyle(
                color: Colors.green.shade400,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
