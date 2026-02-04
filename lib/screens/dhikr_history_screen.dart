import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasbih_provider.dart';

/// Simple Dhikr History Screen - Single unified view
/// Shows data directly from TasbihState (existing tracking)
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
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak card
                    _StreakCard(
                      streakDays: tasbihState.streakDays,
                      totalAllTime: tasbihState.totalAllTime,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick stats row
                    _QuickStats(
                      todayCount: tasbihState.todayCount,
                      monthlyTotal: tasbihState.monthlyTotal,
                      completedTargets: tasbihState.completedTargets,
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Dhikr types breakdown
                    _buildSectionTitle('Dhikr Breakdown'),
                    const SizedBox(height: 12),
                    _DhikrBreakdown(dhikrCounts: tasbihState.dhikrCounts),
                    
                    const SizedBox(height: 28),
                    
                    // Achievements
                    _buildSectionTitle('Achievements'),
                    const SizedBox(height: 12),
                    _AchievementsList(
                      unlockedAchievements: tasbihState.unlockedAchievements,
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
            'Dhikr History',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Streak highlight card
class _StreakCard extends StatelessWidget {
  final int streakDays;
  final int totalAllTime;

  const _StreakCard({
    required this.streakDays,
    required this.totalAllTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF40C463).withValues(alpha: 0.15),
            const Color(0xFF40C463).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF40C463).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text(
                    '$streakDays',
                    style: const TextStyle(
                      color: Color(0xFF40C463),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                streakDays == 1 ? 'Day Streak' : 'Days Streak',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Total all time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(totalAllTime),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Dhikr',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// Quick stats row
class _QuickStats extends StatelessWidget {
  final int todayCount;
  final int monthlyTotal;
  final int completedTargets;

  const _QuickStats({
    required this.todayCount,
    required this.monthlyTotal,
    required this.completedTargets,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            icon: '📅',
            value: '$todayCount',
            label: 'Today',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            icon: '📆',
            value: '$monthlyTotal',
            label: 'This Month',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            icon: '✅',
            value: '$completedTargets',
            label: 'Completed',
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dhikr breakdown - shows count per dhikr type
class _DhikrBreakdown extends StatelessWidget {
  final Map<int, int> dhikrCounts;

  const _DhikrBreakdown({required this.dhikrCounts});

  @override
  Widget build(BuildContext context) {
    if (dhikrCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              const Text('📿', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                'No dhikr recorded yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start counting to see your breakdown',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by count (highest first)
    final sorted = dhikrCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return Column(
      children: sorted.map((entry) {
        final dhikr = Dhikr.presets[entry.key];
        final percentage = maxCount > 0 ? entry.value / maxCount : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dhikr.arabic,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      color: Color(0xFF40C463),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF40C463),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.transliteration,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Achievements list
class _AchievementsList extends StatelessWidget {
  final List<String> unlockedAchievements;

  const _AchievementsList({required this.unlockedAchievements});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: DhikrAchievement.values.map((achievement) {
        final isUnlocked = unlockedAchievements.contains(achievement.name);
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${achievement.emoji} ${achievement.name}: ${achievement.description}',
                ),
                backgroundColor: isUnlocked 
                    ? const Color(0xFF40C463).withValues(alpha: 0.9) 
                    : Colors.grey.withValues(alpha: 0.9),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? const Color(0xFF40C463).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked 
                    ? const Color(0xFF40C463).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                Text(
                  achievement.emoji,
                  style: TextStyle(
                    fontSize: 26,
                    color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.name.split(' ').first,
                  style: TextStyle(
                    color: isUnlocked 
                        ? const Color(0xFF40C463)
                        : Colors.white.withValues(alpha: 0.25),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
