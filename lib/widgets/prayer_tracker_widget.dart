import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prayer_provider.dart';
import '../models/prayer_record.dart';

/// Ultra-Minimalist Prayer Tracker
/// Clean, professional, intuitive design
class PrayerTrackerWidget extends ConsumerWidget {
  final VoidCallback? onExpand;

  const PrayerTrackerWidget({super.key, this.onExpand});

  // Minimal color palette
  static const Color _accentGreen = Color(0xFF40C463);
  static const Color _dimRed = Color(0xFF6E4040);
  static const Color _surface = Color(0xFF161B22);
  static const Color _muted = Color(0xFF484F58);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecord = ref.watch(todayPrayerRecordProvider);
    final recordsMap = ref.watch(prayerRecordsMapProvider);

    // Calculate progress
    final prayers = [
      todayRecord?.fajr ?? false,
      todayRecord?.dhuhr ?? false,
      todayRecord?.asr ?? false,
      todayRecord?.maghrib ?? false,
      todayRecord?.isha ?? false,
    ];
    final completed = prayers.where((p) => p).length;

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _accentGreen.withValues(alpha: completed > 0 ? 0.25 : 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimal header
            Row(
              children: [
                Text(
                  'Salah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Progress dots
                ...List.generate(5, (i) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: prayers[i] ? _accentGreen : _muted,
                    shape: BoxShape.circle,
                  ),
                )),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 18,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Prayer rows - ultra minimal
            _PrayerRow(
              name: 'Fajr',
              isPrayed: todayRecord?.fajr ?? false,
              onToggle: (prayed) => _togglePrayer(ref, 'fajr', prayed),
            ),
            _PrayerRow(
              name: 'Dhuhr',
              isPrayed: todayRecord?.dhuhr ?? false,
              onToggle: (prayed) => _togglePrayer(ref, 'dhuhr', prayed),
            ),
            _PrayerRow(
              name: 'Asr',
              isPrayed: todayRecord?.asr ?? false,
              onToggle: (prayed) => _togglePrayer(ref, 'asr', prayed),
            ),
            _PrayerRow(
              name: 'Maghrib',
              isPrayed: todayRecord?.maghrib ?? false,
              onToggle: (prayed) => _togglePrayer(ref, 'maghrib', prayed),
            ),
            _PrayerRow(
              name: 'Isha',
              isPrayed: todayRecord?.isha ?? false,
              onToggle: (prayed) => _togglePrayer(ref, 'isha', prayed),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  void _togglePrayer(WidgetRef ref, String key, bool prayed) {
    HapticFeedback.lightImpact();
    ref.read(prayerRecordListProvider.notifier).togglePrayer(DateTime.now(), key);
  }
}

/// Single prayer row with toggle buttons
class _PrayerRow extends StatelessWidget {
  final String name;
  final bool isPrayed;
  final Function(bool) onToggle;
  final bool isLast;

  const _PrayerRow({
    required this.name,
    required this.isPrayed,
    required this.onToggle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: Row(
        children: [
          // Prayer name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isPrayed 
                    ? PrayerTrackerWidget._accentGreen 
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: isPrayed ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          
          // Two toggle buttons
          Row(
            children: [
              // Prayed (✓)
              GestureDetector(
                onTap: () => onToggle(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPrayed 
                        ? PrayerTrackerWidget._accentGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPrayed 
                          ? PrayerTrackerWidget._accentGreen.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: isPrayed 
                        ? PrayerTrackerWidget._accentGreen 
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Missed (✗)
              GestureDetector(
                onTap: () => onToggle(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: !isPrayed 
                        ? PrayerTrackerWidget._dimRed.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !isPrayed 
                          ? PrayerTrackerWidget._dimRed
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: !isPrayed 
                        ? const Color(0xFFB56B6B)
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact GitHub-style month contribution grid
class _MonthGrid extends StatelessWidget {
  final Map<String, PrayerRecord> recordsMap;

  const _MonthGrid({required this.recordsMap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Month grid
        Expanded(
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: List.generate(firstWeekday + daysInMonth, (index) {
              if (index < firstWeekday) {
                return const SizedBox(width: 10, height: 10);
              }
              
              final day = index - firstWeekday + 1;
              final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final record = recordsMap[dateKey];
              
              int count = 0;
              if (record != null) {
                if (record.fajr) count++;
                if (record.dhuhr) count++;
                if (record.asr) count++;
                if (record.maghrib) count++;
                if (record.isha) count++;
              }

              final isToday = day == now.day;
              
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _getColor(count),
                  borderRadius: BorderRadius.circular(2),
                  border: isToday 
                      ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1)
                      : null,
                ),
              );
            }),
          ),
        ),
        
        // Month label
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            _getMonthShort(now.month),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(int count) {
    if (count == 5) return const Color(0xFF216E39);
    if (count >= 4) return const Color(0xFF30A14E);
    if (count >= 2) return const Color(0xFF40C463).withValues(alpha: 0.6);
    if (count >= 1) return const Color(0xFF9BE9A8).withValues(alpha: 0.4);
    return const Color(0xFF21262D);
  }

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
