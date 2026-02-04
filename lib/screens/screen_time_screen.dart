import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/usage_stats_provider.dart';
import '../providers/premium_provider.dart';
import 'premium_paywall_screen.dart';

/// Screen Time Analytics Screen - PREMIUM FEATURE
/// Professional analytics dashboard with Islamic-focused insights
class ScreenTimeScreen extends ConsumerStatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  ConsumerState<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends ConsumerState<ScreenTimeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _green = Color(0xFF40C463);
  static const Color _blue = Color(0xFF58A6FF);
  static const Color _orange = Color(0xFFF9826C);
  static const Color _red = Color(0xFFDA3633);
  static const Color _purple = Color(0xFFA371F7);
  static const Color _grey = Color(0xFF6E7681);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(AppCategory category) {
    switch (category) {
      case AppCategory.islamic:
        return _green;
      case AppCategory.productive:
        return _blue;
      case AppCategory.social:
        return _orange;
      case AppCategory.entertainment:
        return _red;
      case AppCategory.messaging:
        return _purple;
      case AppCategory.utility:
        return _grey;
    }
  }

  IconData _getCategoryIcon(AppCategory category) {
    switch (category) {
      case AppCategory.islamic:
        return Icons.mosque;
      case AppCategory.productive:
        return Icons.work_outline;
      case AppCategory.social:
        return Icons.people_outline;
      case AppCategory.entertainment:
        return Icons.movie_outlined;
      case AppCategory.messaging:
        return Icons.chat_bubble_outline;
      case AppCategory.utility:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usageState = ref.watch(usageStatsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: _green,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'This Week'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: usageState.hasPermission
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTodayView(usageState, isPremium),
                        _buildWeeklyView(usageState, isPremium),
                      ],
                    )
                  : _buildPermissionRequest(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'SCREEN TIME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(usageStatsProvider.notifier).refresh();
            },
            child: Icon(
              Icons.refresh,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              color: _green,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Enable Usage Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To analyze your screen time, we need permission to access app usage data. This helps you understand your digital habits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(usageStatsProvider.notifier).requestPermission();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your data stays on your device',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView(UsageStatsState state, bool isPremium) {
    final today = state.todaySummary;
    
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF40C463)),
      );
    }

    if (today == null) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Total time card
          _buildTotalTimeCard(today),
          
          const SizedBox(height: 20),
          
          // Category breakdown
          _buildCategoryBreakdown(today, isPremium),
          
          const SizedBox(height: 20),
          
          // Focus level
          _buildFocusLevelCard(today, isPremium),
          
          const SizedBox(height: 20),
          
          // Top apps
          _buildTopAppsCard(today.topApps, isPremium),
          
          const SizedBox(height: 20),
          
          // Islamic insight
          if (isPremium) _buildIslamicInsight(today),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTotalTimeCard(DailyUsageSummary today) {
    // Compare with yesterday if we have data
    final yesterday = ref.watch(usageStatsProvider).weeklyData.length > 1
        ? ref.watch(usageStatsProvider).weeklyData[ref.watch(usageStatsProvider).weeklyData.length - 2]
        : null;
    
    final diff = yesterday != null 
        ? today.totalMinutes - yesterday.totalMinutes 
        : 0;
    final diffPercent = yesterday != null && yesterday.totalMinutes > 0
        ? ((diff / yesterday.totalMinutes) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _green.withValues(alpha: 0.12),
            _green.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            today.formattedTotal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Screen Time Today',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          if (diffPercent != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: diff < 0 
                    ? _green.withValues(alpha: 0.2)
                    : _orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    diff < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: diff < 0 ? _green : _orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${diffPercent.abs()}% from yesterday',
                    style: TextStyle(
                      color: diff < 0 ? _green : _orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(DailyUsageSummary today, bool isPremium) {
    final categories = [
      (AppCategory.islamic, 'Islamic', today.islamicMinutes, _green),
      (AppCategory.productive, 'Productive', today.productiveMinutes, _blue),
      (AppCategory.social, 'Social', today.socialMinutes, _orange),
      (AppCategory.entertainment, 'Entertainment', today.entertainmentMinutes, _red),
      (AppCategory.messaging, 'Messaging', today.messagingMinutes, _purple),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) => _buildCategoryBar(
            cat.$2,
            cat.$3,
            today.totalMinutes,
            cat.$4,
            _getCategoryIcon(cat.$1),
            isPremium || cat.$1 == AppCategory.islamic, // Always show Islamic
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    String name,
    int minutes,
    int total,
    Color color,
    IconData icon,
    bool visible,
  ) {
    final percentage = total > 0 ? (minutes / total) : 0.0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: visible ? 0.8 : 0.3),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                visible ? timeStr : '••••',
                style: TextStyle(
                  color: visible ? color : Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: visible ? percentage : 0.5,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation(
                visible ? color : Colors.white.withValues(alpha: 0.1),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusLevelCard(DailyUsageSummary today, bool isPremium) {
    final level = today.focusLevel;
    final ratio = today.productiveRatio;
    
    Color levelColor;
    IconData levelIcon;
    switch (level) {
      case 'Master':
        levelColor = _green;
        levelIcon = Icons.emoji_events;
        break;
      case 'Focused':
        levelColor = _blue;
        levelIcon = Icons.psychology;
        break;
      case 'Mindful':
        levelColor = _orange;
        levelIcon = Icons.self_improvement;
        break;
      default:
        levelColor = _grey;
        levelIcon = Icons.directions_walk;
    }

    return GestureDetector(
      onTap: isPremium ? null : () => showPremiumPaywall(context, triggerFeature: 'Focus Level'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: levelColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: levelColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(levelIcon, color: levelColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Focus Level',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium ? level : '????',
                    style: TextStyle(
                      color: isPremium ? levelColor : Colors.white.withValues(alpha: 0.3),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isPremium)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ratio.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Productive',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppsCard(List<AppUsageInfo> apps, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Most Used Apps',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF40C463), Color(0xFF30A14E)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (apps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No app usage data',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...apps.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              final visible = isPremium || index < 2; // Show first 2 for free
              
              return _buildAppRow(app, visible);
            }),
        ],
      ),
    );
  }

  Widget _buildAppRow(AppUsageInfo app, bool visible) {
    final hours = app.usageMinutes ~/ 60;
    final mins = app.usageMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    final color = _getCategoryColor(app.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(app.category),
                color: color,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              visible ? app.appName : '••••••••',
              style: TextStyle(
                color: Colors.white.withValues(alpha: visible ? 0.8 : 0.3),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            visible ? timeStr : '••••',
            style: TextStyle(
              color: visible ? color : Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicInsight(DailyUsageSummary today) {
    String insight;
    IconData icon;
    
    if (today.islamicMinutes > 30) {
      insight = 'MashAllah! You\'ve spent ${today.islamicMinutes}m on Islamic content today. Keep it up!';
      icon = Icons.favorite;
    } else if (today.socialMinutes > today.islamicMinutes * 3) {
      insight = 'Consider balancing ${today.socialMinutes}m on social apps with more Quran time.';
      icon = Icons.lightbulb_outline;
    } else if (today.totalMinutes > 300) {
      insight = 'Try enabling Deen Mode to reduce screen time and focus on what matters.';
      icon = Icons.self_improvement;
    } else {
      insight = 'Great balance today! Your screen time is well-managed.';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _green.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(UsageStatsState state, bool isPremium) {
    final weeklyData = state.weeklyData;
    
    if (weeklyData.isEmpty) {
      return Center(
        child: Text(
          'No weekly data available',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    final maxMinutes = weeklyData.map((d) => d.totalMinutes).reduce((a, b) => a > b ? a : b);
    final avgMinutes = weeklyData.map((d) => d.totalMinutes).reduce((a, b) => a + b) ~/ 7;
    final avgHours = avgMinutes ~/ 60;
    final avgMins = avgMinutes % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Weekly average
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _blue.withValues(alpha: 0.12),
                  _blue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _blue.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${avgHours}h ${avgMins}m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Average This Week',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Weekly bar chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Overview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isToday = index == weeklyData.length - 1;
                      final heightRatio = maxMinutes > 0 
                          ? data.totalMinutes / maxMinutes 
                          : 0.0;
                      
                      final day = DateFormat('E').format(data.date);
                      final visible = isPremium || isToday;
                      
                      return _buildDayBar(
                        day,
                        heightRatio,
                        data.formattedTotal,
                        isToday,
                        visible,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Weekly stats
          if (isPremium) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Best Day',
                    DateFormat('EEEE').format(
                      weeklyData.reduce((a, b) => 
                        a.totalMinutes < b.totalMinutes ? a : b
                      ).date,
                    ),
                    Icons.emoji_events,
                    _green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Islamic Time',
                    '${weeklyData.map((d) => d.islamicMinutes).reduce((a, b) => a + b)}m',
                    Icons.mosque,
                    _green,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDayBar(
    String day,
    double heightRatio,
    String time,
    bool isToday,
    bool visible,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (visible)
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
            ),
          )
        else
          Text(
            '••',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 9,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 100 * heightRatio + 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isToday
                  ? [_green, _green.withValues(alpha: 0.7)]
                  : visible
                      ? [_blue.withValues(alpha: 0.6), _blue.withValues(alpha: 0.3)]
                      : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday
                ? _green
                : Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
