import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasbih_provider.dart';

/// Dhikr Dashboard - Complete history with date/month wise data
class DhikrHistoryScreen extends ConsumerWidget {
  const DhikrHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihState = ref.watch(tasbihProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Overview
                    _StatsOverview(state: tasbihState),
                    
                    const SizedBox(height: 24),
                    
                    // Date-wise Section
                    _SectionTitle(title: 'This Week'),
                    const SizedBox(height: 12),
                    _DateWiseStats(state: tasbihState),
                    
                    const SizedBox(height: 24),
                    
                    // Month-wise Section
                    _SectionTitle(title: 'Monthly Progress'),
                    const SizedBox(height: 12),
                    _MonthWiseStats(state: tasbihState),
                    
                    const SizedBox(height: 24),
                    
                    // Dhikr Breakdown
                    _SectionTitle(title: 'Dhikr Breakdown'),
                    const SizedBox(height: 12),
                    _DhikrBreakdown(dhikrCounts: tasbihState.dhikrCounts),
                    
                    const SizedBox(height: 24),
                    
                    // Achievements - Horizontal scroll
                    _SectionTitle(title: 'Achievements'),
                    const SizedBox(height: 12),
                    _AchievementsRow(
                      unlockedAchievements: tasbihState.unlockedAchievements,
                      totalAllTime: tasbihState.totalAllTime,
                      streakDays: tasbihState.streakDays,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Dhikr Dashboard',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Stats Overview Card
class _StatsOverview extends StatelessWidget {
  final TasbihState state;
  const _StatsOverview({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF40C463).withValues(alpha: 0.12),
            const Color(0xFF40C463).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF40C463).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Streak
          Expanded(
            child: _OverviewStat(
              icon: '🔥',
              value: '${state.streakDays}',
              label: 'Streak',
              highlight: state.streakDays > 0,
            ),
          ),
          _verticalDivider(),
          // Total
          Expanded(
            child: _OverviewStat(
              icon: '📿',
              value: _formatNumber(state.totalAllTime),
              label: 'Total',
              highlight: false,
            ),
          ),
          _verticalDivider(),
          // Today
          Expanded(
            child: _OverviewStat(
              icon: '📅',
              value: '${state.todayCount}',
              label: 'Today',
              highlight: state.todayCount > 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _OverviewStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool highlight;

  const _OverviewStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFF40C463) : Colors.white.withValues(alpha: 0.85),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Date-wise stats - Last 7 days
class _DateWiseStats extends StatelessWidget {
  final TasbihState state;
  const _DateWiseStats({required this.state});

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    
    // Generate last 7 days data
    final days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return {
        'day': weekdays[day.weekday - 1],
        'date': day.day,
        'isToday': i == 6,
        // For now, show today's count only on today, otherwise 0
        'count': i == 6 ? state.todayCount : 0,
      };
    });
    
    final maxCount = state.todayCount > 0 ? state.todayCount : 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          final count = day['count'] as int;
          final isToday = day['isToday'] as bool;
          final barHeight = count > 0 ? (count / maxCount * 50).clamp(8.0, 50.0) : 4.0;
          
          return Column(
            children: [
              // Bar
              Container(
                width: 24,
                height: 50,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 24,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isToday 
                        ? const Color(0xFF40C463)
                        : count > 0 
                            ? const Color(0xFF40C463).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Count
              Text(
                count > 0 ? '$count' : '-',
                style: TextStyle(
                  color: isToday 
                      ? const Color(0xFF40C463)
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // Day name
              Text(
                day['day'] as String,
                style: TextStyle(
                  color: isToday 
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Month-wise stats
class _MonthWiseStats extends StatelessWidget {
  final TasbihState state;
  const _MonthWiseStats({required this.state});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentMonth = DateTime.now().month - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                months[currentMonth],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${DateTime.now().year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${state.monthlyTotal}',
                style: const TextStyle(
                  color: Color(0xFF40C463),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' dhikr',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MonthStat(label: 'Daily Avg', value: '${(state.monthlyTotal / DateTime.now().day).round()}'),
              const SizedBox(width: 20),
              _MonthStat(label: 'Completed', value: '${state.completedTargets}'),
              const SizedBox(width: 20),
              _MonthStat(label: 'Best Day', value: '${state.todayCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String label;
  final String value;
  const _MonthStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Dhikr breakdown
class _DhikrBreakdown extends StatelessWidget {
  final Map<int, int> dhikrCounts;
  const _DhikrBreakdown({required this.dhikrCounts});

  @override
  Widget build(BuildContext context) {
    if (dhikrCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'Start counting to see breakdown',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final sorted = dhikrCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return Column(
      children: sorted.take(5).map((entry) {
        final dhikr = Dhikr.presets[entry.key];
        final percentage = maxCount > 0 ? entry.value / maxCount : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Arabic
              Expanded(
                flex: 2,
                child: Text(
                  dhikr.arabic,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Progress bar
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF40C463),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Count
              Text(
                '${entry.value}',
                style: const TextStyle(
                  color: Color(0xFF40C463),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Achievements - Horizontal scrollable row
class _AchievementsRow extends StatelessWidget {
  final List<String> unlockedAchievements;
  final int totalAllTime;
  final int streakDays;
  
  const _AchievementsRow({
    required this.unlockedAchievements,
    required this.totalAllTime,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = DhikrAchievement.values;
    
    // Find next locked achievement
    int? nextTargetIndex;
    for (int i = 0; i < achievements.length; i++) {
      if (!unlockedAchievements.contains(achievements[i].name)) {
        nextTargetIndex = i;
        break;
      }
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = unlockedAchievements.contains(achievement.name);
          final isNextTarget = index == nextTargetIndex;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showAchievementInfo(context, achievement, isUnlocked, isNextTarget);
            },
            child: Container(
              width: 75,
              margin: EdgeInsets.only(right: index < achievements.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? const Color(0xFF40C463).withValues(alpha: 0.12)
                    : isNextTarget
                        ? Colors.amber.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked 
                      ? const Color(0xFF40C463).withValues(alpha: 0.3)
                      : isNextTarget
                          ? Colors.amber.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.04),
                  width: isNextTarget ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon/Emoji
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        achievement.emoji,
                        style: TextStyle(
                          fontSize: 28,
                          color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      if (!isUnlocked && !isNextTarget)
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      if (isNextTarget)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Status label
                  Text(
                    isUnlocked 
                        ? '✓' 
                        : isNextTarget 
                            ? 'Next'
                            : '🔒',
                    style: TextStyle(
                      color: isUnlocked 
                          ? const Color(0xFF40C463)
                          : isNextTarget
                              ? Colors.amber
                              : Colors.white.withValues(alpha: 0.2),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAchievementInfo(BuildContext context, DhikrAchievement achievement, bool isUnlocked, bool isNextTarget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: TextStyle(
                color: isUnlocked ? const Color(0xFF40C463) : Colors.white.withValues(alpha: 0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? const Color(0xFF40C463).withValues(alpha: 0.15)
                    : isNextTarget
                        ? Colors.amber.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUnlocked 
                    ? '✓ Unlocked!' 
                    : isNextTarget
                        ? '🎯 Your Next Goal'
                        : '🔒 Locked',
                style: TextStyle(
                  color: isUnlocked 
                      ? const Color(0xFF40C463)
                      : isNextTarget
                          ? Colors.amber
                          : Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
