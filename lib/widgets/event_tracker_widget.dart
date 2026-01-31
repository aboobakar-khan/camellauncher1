import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/theme_provider.dart';
import '../models/event.dart';

/// Event Tracker Widget - Shows upcoming events
class EventTrackerWidget extends ConsumerStatefulWidget {
  final VoidCallback? onExpand;

  const EventTrackerWidget({super.key, this.onExpand});

  @override
  ConsumerState<EventTrackerWidget> createState() => _EventTrackerWidgetState();
}

class _EventTrackerWidgetState extends ConsumerState<EventTrackerWidget> {
  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'UPCOMING EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                      color: themeColor.color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showAddEventDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: themeColor.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    color: themeColor.color.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Events list or empty state
          if (upcomingEvents.isEmpty)
            _buildEmptyState(themeColor)
          else
            _buildEventsList(upcomingEvents, themeColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColor themeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming events',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAddEventDialog(context),
              child: Text(
                'Tap + to add an event',
                style: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, AppThemeColor themeColor) {
    // Show max 5 upcoming events in widget
    final displayEvents = events.take(5).toList();

    return Column(
      children: [
        ...displayEvents.map((event) => _buildEventItem(event, themeColor)),
        if (events.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: widget.onExpand,
              child: Text(
                '+ ${events.length - 5} more events',
                style: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventItem(Event event, AppThemeColor themeColor) {
    final daysUntil = event.daysUntil;
    final timeFormat = DateFormat('h:mm a');

    // Determine urgency color
    Color urgencyColor;
    if (daysUntil == 0) {
      urgencyColor = Colors.red.shade400;
    } else if (daysUntil <= 3) {
      urgencyColor = Colors.orange.shade400;
    } else if (daysUntil <= 7) {
      urgencyColor = Colors.yellow.shade600;
    } else {
      urgencyColor = themeColor.color;
    }

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
      ),
      onDismissed: (_) {
        ref.read(eventListProvider.notifier).deleteEvent(event.id);
      },
      child: GestureDetector(
        onTap: () => _showEditEventDialog(context, event),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: urgencyColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(event.eventDate),
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(event.eventDate).toUpperCase(),
                      style: TextStyle(
                        color: urgencyColor.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (!event.isAllDay) ...[
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(event.eventDate),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _getDaysUntilText(daysUntil),
                          style: TextStyle(
                            color: urgencyColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDaysUntilText(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';
    if (days < 30) return 'In ${(days / 7).floor()} weeks';
    return 'In ${(days / 30).floor()} months';
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isAllDay = true;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final themeColor = ref.watch(themeColorProvider);

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.event_note, color: themeColor.color, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Add Event',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title field
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Event title',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description field
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: themeColor.color,
                                surface: Colors.grey[900]!,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: themeColor.color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('MMM d, yyyy').format(selectedDate),
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // All day toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All day',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      Switch(
                        value: isAllDay,
                        onChanged: (value) {
                          setDialogState(() => isAllDay = value);
                        },
                        activeColor: themeColor.color,
                      ),
                    ],
                  ),

                  // Time picker (if not all day)
                  if (!isAllDay) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: themeColor.color,
                                  surface: Colors.grey[900]!,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: themeColor.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedTime.format(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  DateTime eventDateTime = selectedDate;
                  if (!isAllDay) {
                    eventDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                  }

                  ref
                      .read(eventListProvider.notifier)
                      .addEvent(
                        title: titleController.text,
                        description: descController.text.isEmpty
                            ? null
                            : descController.text,
                        eventDate: eventDateTime,
                        isAllDay: isAllDay,
                      );
                  Navigator.pop(context);
                },
                child: Text('Add', style: TextStyle(color: themeColor.color)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description ?? '');
    DateTime selectedDate = event.eventDate;
    bool isAllDay = event.isAllDay;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(event.eventDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final themeColor = ref.watch(themeColorProvider);

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.edit, color: themeColor.color, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Edit Event',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Event title',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: themeColor.color,
                                surface: Colors.grey[900]!,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: themeColor.color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('MMM d, yyyy').format(selectedDate),
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All day',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      Switch(
                        value: isAllDay,
                        onChanged: (value) {
                          setDialogState(() => isAllDay = value);
                        },
                        activeColor: themeColor.color,
                      ),
                    ],
                  ),
                  if (!isAllDay) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: themeColor.color,
                                  surface: Colors.grey[900]!,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: themeColor.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedTime.format(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(eventListProvider.notifier).deleteEvent(event.id);
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red[400])),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  DateTime eventDateTime = selectedDate;
                  if (!isAllDay) {
                    eventDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                  }

                  ref
                      .read(eventListProvider.notifier)
                      .updateEvent(
                        event.id,
                        title: titleController.text,
                        description: descController.text.isEmpty
                            ? null
                            : descController.text,
                        eventDate: eventDateTime,
                        isAllDay: isAllDay,
                      );
                  Navigator.pop(context);
                },
                child: Text('Save', style: TextStyle(color: themeColor.color)),
              ),
            ],
          );
        },
      ),
    );
  }
}
