import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import '../providers/theme_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/widget_card.dart';

/// Calendar widget for dashboard
class CalendarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onExpand;

  const CalendarWidget({super.key, this.onExpand});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Get Islamic date
    final hijriDate = HijriCalendar.fromDate(_focusedDay);
    final themeColor = ref.watch(themeColorProvider);
    final eventDates = ref.watch(eventDatesProvider);
    final selectedDayEvents = _selectedDay != null
        ? ref.watch(eventsForDateProvider(_selectedDay!))
        : [];

    return WidgetCard(
      title: 'Calendar',
      height: _selectedDay != null && selectedDayEvents.isNotEmpty ? 500 : 420,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: widget.onExpand,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              // Event markers
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return eventDates.contains(normalizedDay) ? [true] : [];
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: HeaderStyle(
                titleCentered: false,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.7),
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w400,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
                leftChevronMargin: const EdgeInsets.all(0),
                rightChevronMargin: const EdgeInsets.all(0),
                headerPadding: const EdgeInsets.only(bottom: 8),
              ),
              daysOfWeekHeight: 20,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                weekendStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              rowHeight: 36,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                cellMargin: const EdgeInsets.all(4),
                defaultTextStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                weekendTextStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 1.0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                // Event marker style
                markerDecoration: BoxDecoration(
                  color: themeColor.color,
                  shape: BoxShape.circle,
                ),
                markerSize: 5,
                markersMaxCount: 1,
                markerMargin: const EdgeInsets.only(top: 1),
              ),
            ),

            const SizedBox(height: 16),

            // Show events for selected day
            if (_selectedDay != null && selectedDayEvents.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: themeColor.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(_selectedDay!),
                      style: TextStyle(
                        color: themeColor.color.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...selectedDayEvents.map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: themeColor.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Islamic Calendar Date
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: const Color.fromARGB(255, 133, 252, 137),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} AH',
                    style: TextStyle(
                      color: themeColor.color.withValues(alpha: 0.7),
                      fontSize: 13,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
