import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prayer_provider.dart';
import '../models/prayer_record.dart';

/// Prayer Tracker Widget - Current month view with green theme
class PrayerTrackerWidget extends ConsumerWidget {
  final VoidCallback? onExpand;

  const PrayerTrackerWidget({super.key, this.onExpand});

  // Green color palette
  static const Color _greenLight = Color(0xFF9BE9A8);
  static const Color _greenMid = Color(0xFF40C463);
  static const Color _greenDark = Color(0xFF30A14E);
  static const Color _greenDarkest = Color(0xFF216E39);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecord = ref.watch(todayPrayerRecordProvider);
    final recordsMap = ref.watch(prayerRecordsMapProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Today's prayers with icons
          _buildTodayPrayers(ref, todayRecord),

          const SizedBox(height: 20),

          // Month header
          _buildMonthHeader(),

          const SizedBox(height: 12),

          // Current month grid
          _buildCurrentMonthGrid(recordsMap),

          const SizedBox(height: 10),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildTodayPrayers(WidgetRef ref, PrayerRecord? todayRecord) {
    final prayers = [
      ('Fajr', 'fajr', Icons.nightlight_round, todayRecord?.fajr ?? false),
      ('Dhuhr', 'dhuhr', Icons.wb_sunny, todayRecord?.dhuhr ?? false),
      ('Asr', 'asr', Icons.wb_twilight, todayRecord?.asr ?? false),
      ('Maghrib', 'maghrib', Icons.nights_stay, todayRecord?.maghrib ?? false),
      ('Isha', 'isha', Icons.dark_mode, todayRecord?.isha ?? false),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        final (name, key, icon, isCompleted) = prayer;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(prayerRecordListProvider.notifier).togglePrayer(DateTime.now(), key);
          },
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted ? _greenDark : const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted ? _greenMid : const Color(0xFF30363D),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  color: isCompleted ? Colors.white : const Color(0xFF6E7681),
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
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
    );
  }

  Widget _buildMonthHeader() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Text(
      '${months[now.month - 1]} ${now.year}',
      style: const TextStyle(
        color: Color(0xFF8B949E),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCurrentMonthGrid(Map<String, PrayerRecord> recordsMap) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Day names
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    // Build week rows
    final weeks = <List<int?>>[];
    var currentWeek = <int?>[];
    
    // Add empty cells for days before the 1st
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(null);
    }
    
    // Add all days
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    
    // Complete last week with empty cells
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      children: [
        // Day name headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames.map((day) {
            return SizedBox(
              width: 36,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6E7681),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Week rows
        ...weeks.map((week) => _buildWeekRow(week, recordsMap, now)),
      ],
    );
  }

  Widget _buildWeekRow(List<int?> week, Map<String, PrayerRecord> recordsMap, DateTime now) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: week.map((day) {
          if (day == null) {
            return const SizedBox(width: 36, height: 36);
          }
          
          final date = DateTime(now.year, now.month, day);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final record = recordsMap[dateKey];
          final count = record?.completedCount ?? 0;
          final isToday = day == now.day;
          final isFuture = day > now.day;
          
          return _buildDayCell(day, count, isToday, isFuture);
        }).toList(),
      ),
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
    } else if (count == 1) {
      bgColor = _greenLight.withValues(alpha: 0.4);
      textColor = Colors.white;
    } else if (count == 2) {
      bgColor = _greenLight.withValues(alpha: 0.7);
      textColor = Colors.white;
    } else if (count == 3) {
      bgColor = _greenMid;
      textColor = Colors.white;
    } else if (count == 4) {
      bgColor = _greenDark;
      textColor = Colors.white;
    } else {
      bgColor = _greenDarkest;
      textColor = Colors.white;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: _greenLight, width: 2)
            : null,
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
        _legendItem(_greenLight.withValues(alpha: 0.5), '1-2'),
        _legendItem(_greenMid, '3-4'),
        _legendItem(_greenDarkest, '5'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6E7681),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
