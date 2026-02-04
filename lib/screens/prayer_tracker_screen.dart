import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prayer_provider.dart';
import '../models/prayer_record.dart';

/// Full-screen Prayer Tracker Page
/// - Stats summary at top
/// - Today & Yesterday editable
/// - History calendar (read-only, tap to view details)
class PrayerTrackerScreen extends ConsumerStatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  ConsumerState<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends ConsumerState<PrayerTrackerScreen> {
  int _selectedMonthOffset = 0; // 0 = current month, -1 = last month, etc.

  // Green color palette
  static const Color _greenLight = Color(0xFF9BE9A8);
  static const Color _greenMid = Color(0xFF40C463);
  static const Color _greenDark = Color(0xFF30A14E);
  static const Color _greenDarkest = Color(0xFF216E39);
  static const Color _bgDark = Color(0xFF0D1117);
  static const Color _cardBg = Color(0xFF161B22);
  static const Color _borderColor = Color(0xFF30363D);

  @override
  Widget build(BuildContext context) {
    final recordsMap = ref.watch(prayerRecordsMapProvider);
    final todayRecord = ref.watch(todayPrayerRecordProvider);
    final allRecords = ref.watch(prayerRecordListProvider);

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: _buildStatsCards(allRecords, recordsMap),
            ),

            // Today's Prayers (Editable)
            SliverToBoxAdapter(
              child: _buildEditableSection(
                'TODAY',
                DateTime.now(),
                todayRecord,
                isEditable: true,
              ),
            ),

            // Yesterday's Prayers (Editable)
            SliverToBoxAdapter(
              child: _buildEditableSection(
                'YESTERDAY',
                DateTime.now().subtract(const Duration(days: 1)),
                _getRecordForDate(recordsMap, DateTime.now().subtract(const Duration(days: 1))),
                isEditable: true,
              ),
            ),

            // Calendar History
            SliverToBoxAdapter(
              child: _buildCalendarSection(recordsMap),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prayer Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Track your daily salah',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _greenDark.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mosque,
              color: _greenMid,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<PrayerRecord> allRecords, Map<String, PrayerRecord> recordsMap) {
    // Calculate stats
    final streak = _calculateCurrentStreak(recordsMap);
    final bestStreak = _calculateBestStreak(recordsMap);
    final weeklyAvg = _calculateWeeklyAverage(recordsMap);
    final monthlyStats = _calculateMonthlyStats(recordsMap);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row - Streak cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  label: 'Current Streak',
                  value: '$streak',
                  suffix: 'days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  iconColor: Colors.amber,
                  label: 'Best Streak',
                  value: '$bestStreak',
                  suffix: 'days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row - Average and Monthly
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  iconColor: _greenMid,
                  label: 'Weekly Avg',
                  value: weeklyAvg.toStringAsFixed(1),
                  suffix: '/5',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_month,
                  iconColor: Colors.blue,
                  label: 'This Month',
                  value: '${monthlyStats['completed']}',
                  suffix: '/${monthlyStats['total']}',
                  progressValue: monthlyStats['total']! > 0
                      ? monthlyStats['completed']! / monthlyStats['total']!
                      : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String suffix,
    double? progressValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  suffix,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(iconColor),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditableSection(String title, DateTime date, PrayerRecord? record, {required bool isEditable}) {
    final prayers = [
      ('Fajr', 'fajr', Icons.nightlight_round, record?.fajr ?? false),
      ('Dhuhr', 'dhuhr', Icons.wb_sunny, record?.dhuhr ?? false),
      ('Asr', 'asr', Icons.wb_twilight, record?.asr ?? false),
      ('Maghrib', 'maghrib', Icons.nights_stay, record?.maghrib ?? false),
      ('Isha', 'isha', Icons.dark_mode, record?.isha ?? false),
    ];

    final completedCount = record?.completedCount ?? 0;
    final dateStr = _formatDate(date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: title == 'TODAY' 
                      ? _greenMid.withValues(alpha: 0.2) 
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: title == 'TODAY' ? _greenMid : Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                dateStr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completedCount == 5 
                      ? _greenDark.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount/5',
                  style: TextStyle(
                    color: completedCount == 5 ? _greenLight : Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Prayer toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((prayer) {
              final (name, key, icon, isCompleted) = prayer;
              return GestureDetector(
                onTap: isEditable
                    ? () {
                        HapticFeedback.lightImpact();
                        ref.read(prayerRecordListProvider.notifier).togglePrayer(date, key);
                      }
                    : null,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isCompleted ? _greenDark : const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCompleted ? _greenMid : _borderColor,
                          width: 1.5,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: _greenMid.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_rounded : icon,
                        color: isCompleted ? Colors.white : const Color(0xFF6E7681),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: TextStyle(
                        color: isCompleted ? _greenLight : const Color(0xFF8B949E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(Map<String, PrayerRecord> recordsMap) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month + _selectedMonthOffset, 1);
    final monthName = _getMonthName(targetMonth.month);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTORY',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedMonthOffset--),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$monthName ${targetMonth.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _selectedMonthOffset < 0
                        ? () => setState(() => _selectedMonthOffset++)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: _selectedMonthOffset < 0 ? 0.05 : 0.02),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white.withValues(alpha: _selectedMonthOffset < 0 ? 0.5 : 0.2),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Calendar grid
          _buildCalendarGrid(targetMonth, recordsMap),
          const SizedBox(height: 12),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month, Map<String, PrayerRecord> recordsMap) {
    final now = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    final weeks = <List<int?>>[];
    var currentWeek = <int?>[];
    
    final firstWeekday = firstDay.weekday % 7;
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(null);
    }
    
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      children: [
        // Day headers
        Row(
          children: dayNames.map((d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Weeks
        ...weeks.map((week) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: week.map((day) {
              if (day == null) {
                return const Expanded(child: SizedBox(height: 36));
              }
              
              final date = DateTime(month.year, month.month, day);
              final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final record = recordsMap[dateKey];
              final count = record?.completedCount ?? 0;
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isFuture = date.isAfter(now);
              
              return Expanded(
                child: GestureDetector(
                  onTap: isFuture ? null : () => _showDayDetails(date, record),
                  child: _buildDayCell(day, count, isToday, isFuture),
                ),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }

  Widget _buildDayCell(int day, int count, bool isToday, bool isFuture) {
    Color bgColor;
    Color textColor;
    
    if (isFuture) {
      bgColor = Colors.transparent;
      textColor = const Color(0xFF484F58);
    } else if (count == 0) {
      bgColor = const Color(0xFF21262D);
      textColor = const Color(0xFF8B949E);
    } else if (count <= 2) {
      bgColor = _greenLight.withValues(alpha: 0.3 + (count * 0.15));
      textColor = Colors.white;
    } else if (count <= 4) {
      bgColor = _greenMid.withValues(alpha: 0.6 + ((count - 2) * 0.15));
      textColor = Colors.white;
    } else {
      bgColor = _greenDarkest;
      textColor = Colors.white;
    }

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: _greenLight, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF21262D), '0'),
        _legendItem(_greenLight.withValues(alpha: 0.4), '1-2'),
        _legendItem(_greenMid, '3-4'),
        _legendItem(_greenDarkest, '5'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
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

  void _showDayDetails(DateTime date, PrayerRecord? record) {
    final now = DateTime.now();
    final isYesterday = date.year == now.year && 
                        date.month == now.month && 
                        date.day == now.day - 1;
    final isToday = date.year == now.year && 
                    date.month == now.month && 
                    date.day == now.day;
    final isEditable = isToday || isYesterday;

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DayDetailSheet(
        date: date,
        record: record,
        isEditable: isEditable,
        onToggle: isEditable
            ? (prayerKey) {
                ref.read(prayerRecordListProvider.notifier).togglePrayer(date, prayerKey);
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }

  // Helper methods
  PrayerRecord? _getRecordForDate(Map<String, PrayerRecord> map, DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return map[key];
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  int _calculateCurrentStreak(Map<String, PrayerRecord> recordsMap) {
    int streak = 0;
    var date = DateTime.now();
    
    while (true) {
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final record = recordsMap[key];
      
      if (record == null || record.completedCount < 5) {
        break;
      }
      
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  int _calculateBestStreak(Map<String, PrayerRecord> recordsMap) {
    if (recordsMap.isEmpty) return 0;
    
    final sortedKeys = recordsMap.keys.toList()..sort();
    int bestStreak = 0;
    int currentStreak = 0;
    
    for (final key in sortedKeys) {
      final record = recordsMap[key];
      if (record != null && record.completedCount == 5) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }
    
    return bestStreak;
  }

  double _calculateWeeklyAverage(Map<String, PrayerRecord> recordsMap) {
    final now = DateTime.now();
    int totalPrayers = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final record = recordsMap[key];
      
      if (record != null) {
        totalPrayers += record.completedCount;
        daysWithData++;
      }
    }
    
    return daysWithData > 0 ? totalPrayers / daysWithData : 0;
  }

  Map<String, int> _calculateMonthlyStats(Map<String, PrayerRecord> recordsMap) {
    final now = DateTime.now();
    int completed = 0;
    int total = now.day * 5; // Days passed * 5 prayers
    
    for (int day = 1; day <= now.day; day++) {
      final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final record = recordsMap[key];
      if (record != null) {
        completed += record.completedCount;
      }
    }
    
    return {'completed': completed, 'total': total};
  }
}

/// Bottom sheet for day details
class _DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final PrayerRecord? record;
  final bool isEditable;
  final Function(String)? onToggle;

  const _DayDetailSheet({
    required this.date,
    required this.record,
    required this.isEditable,
    this.onToggle,
  });

  static const Color _greenLight = Color(0xFF9BE9A8);
  static const Color _greenMid = Color(0xFF40C463);
  static const Color _greenDark = Color(0xFF30A14E);

  @override
  Widget build(BuildContext context) {
    final prayers = [
      ('Fajr', 'fajr', Icons.nightlight_round, record?.fajr ?? false),
      ('Dhuhr', 'dhuhr', Icons.wb_sunny, record?.dhuhr ?? false),
      ('Asr', 'asr', Icons.wb_twilight, record?.asr ?? false),
      ('Maghrib', 'maghrib', Icons.nights_stay, record?.maghrib ?? false),
      ('Isha', 'isha', Icons.dark_mode, record?.isha ?? false),
    ];

    final completedCount = record?.completedCount ?? 0;
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Date header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${months[date.month - 1]} ${date.day}, ${date.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditable ? 'Tap to edit' : 'View only',
                    style: TextStyle(
                      color: isEditable ? _greenMid : Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: completedCount == 5 
                      ? _greenDark.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/5',
                  style: TextStyle(
                    color: completedCount == 5 ? _greenLight : Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Prayer list
          ...prayers.map((prayer) {
            final (name, key, icon, isCompleted) = prayer;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: isEditable ? () => onToggle?.call(key) : null,
                leading: Icon(
                  icon,
                  color: isCompleted ? _greenMid : Colors.white.withValues(alpha: 0.3),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? _greenDark : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted ? _greenMid : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
