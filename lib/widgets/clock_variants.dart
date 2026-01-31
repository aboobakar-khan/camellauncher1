import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../providers/time_format_provider.dart';

/// Digital Clock Widget - Classic digital display
class DigitalClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const DigitalClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _dayOfWeek => DateFormat('EEEE').format(time).toUpperCase();
  String get _date => DateFormat('MMMM d').format(time);
  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm a').format(time)
      : DateFormat('HH:mm').format(time);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _dayOfWeek,
          style: TextStyle(
            fontSize: 48,
            letterSpacing: 8,
            fontWeight: FontWeight.w200,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _date,
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.6 * opacityMultiplier),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _time,
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
          ),
        ),
      ],
    );
  }
}

/// Analog Clock Widget - Traditional clock face
class AnalogClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final double opacityMultiplier;

  const AnalogClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    this.opacityMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Clock face
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: ClockPainter(time: time, themeColor: themeColor),
          ),
        ),
        const SizedBox(height: 24),
        // Date below clock
        Text(
          DateFormat('EEEE, MMMM d').format(time),
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.7 * opacityMultiplier),
          ),
        ),
      ],
    );
  }
}

/// Minimalist Clock Widget - Minimal design
class MinimalistClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const MinimalistClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm a').format(time)
      : DateFormat('HH:mm').format(time);
  String get _date => DateFormat('EEE, MMM d').format(time);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _time,
          style: TextStyle(
            fontSize: 72,
            letterSpacing: 6,
            fontWeight: FontWeight.w100,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _date,
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.5 * opacityMultiplier),
          ),
        ),
      ],
    );
  }
}

/// Bold Clock Widget - Large and prominent
class BoldClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const BoldClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm a').format(time)
      : DateFormat('HH:mm').format(time);
  String get _dayOfWeek => DateFormat('EEEE').format(time).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _time,
          style: TextStyle(
            fontSize: 96,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _dayOfWeek,
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 6,
            fontWeight: FontWeight.w500,
            color: themeColor.color.withValues(alpha: 0.6 * opacityMultiplier),
          ),
        ),
      ],
    );
  }
}

/// Compact Clock Widget - Space-saving layout
class CompactClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const CompactClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm a').format(time)
      : DateFormat('HH:mm').format(time);
  String get _date => DateFormat('MMM d').format(time);
  String get _day => DateFormat('EEE').format(time);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _time,
          style: TextStyle(
            fontSize: 60,
            letterSpacing: 1,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _day.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w400,
                color: themeColor.color.withValues(
                  alpha: 0.7 * opacityMultiplier,
                ),
              ),
            ),
            Text(
              _date,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1,
                fontWeight: FontWeight.w300,
                color: themeColor.color.withValues(
                  alpha: 0.5 * opacityMultiplier,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for analog clock
class ClockPainter extends CustomPainter {
  final DateTime time;
  final AppThemeColor themeColor;

  ClockPainter({required this.time, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Draw clock circle
    final circlePaint = Paint()
      ..color = themeColor.color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Draw hour markers
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final start = Offset(
        center.dx + (radius - 20) * cos(angle),
        center.dy + (radius - 20) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 10) * cos(angle),
        center.dy + (radius - 10) * sin(angle),
      );
      final markerPaint = Paint()
        ..color = themeColor.color.withValues(alpha: 0.9)
        ..strokeWidth = 2;
      canvas.drawLine(start, end, markerPaint);
    }

    // Draw hour hand
    final hourAngle =
        ((time.hour % 12) * 30 + time.minute * 0.5 - 90) * pi / 180;
    final hourHand = Offset(
      center.dx + radius * 0.4 * cos(hourAngle),
      center.dy + radius * 0.4 * sin(hourAngle),
    );
    final hourPaint = Paint()
      ..color = themeColor.color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, hourHand, hourPaint);

    // Draw minute hand
    final minuteAngle = (time.minute * 6 - 90) * pi / 180;
    final minuteHand = Offset(
      center.dx + radius * 0.6 * cos(minuteAngle),
      center.dy + radius * 0.6 * sin(minuteAngle),
    );
    final minutePaint = Paint()
      ..color = themeColor.color.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, minuteHand, minutePaint);

    // Draw center dot
    final centerPaint = Paint()..color = themeColor.color;
    canvas.drawCircle(center, 6, centerPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => true;
}

/// Modern Clock Widget - Sleek contemporary style
class ModernClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const ModernClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm').format(time)
      : DateFormat('HH:mm').format(time);
  String get _period =>
      timeFormat == TimeFormat.hour12 ? DateFormat('a').format(time) : '';
  String get _seconds => DateFormat('ss').format(time);
  String get _date => DateFormat('EEEE, MMMM d').format(time);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _time,
              style: TextStyle(
                fontSize: 80,
                letterSpacing: 2,
                fontWeight: FontWeight.w200,
                color: themeColor.color.withValues(alpha: opacityMultiplier),
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _seconds,
                    style: TextStyle(
                      fontSize: 24,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w200,
                      color: themeColor.color.withValues(
                        alpha: 0.5 * opacityMultiplier,
                      ),
                    ),
                  ),
                  if (_period.isNotEmpty)
                    Text(
                      _period,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300,
                        color: themeColor.color.withValues(
                          alpha: 0.6 * opacityMultiplier,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeColor.color.withValues(
                alpha: 0.3 * opacityMultiplier,
              ),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _date,
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
              color: themeColor.color.withValues(
                alpha: 0.7 * opacityMultiplier,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Retro Clock Widget - Vintage flip-clock style
class RetroClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const RetroClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _hour => timeFormat == TimeFormat.hour12
      ? DateFormat('hh').format(time)
      : DateFormat('HH').format(time);
  String get _minute => DateFormat('mm').format(time);
  String get _period =>
      timeFormat == TimeFormat.hour12 ? DateFormat('a').format(time) : '';
  String get _date => DateFormat('EEE, MMM d').format(time).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlipDigit(_hour[0]),
            const SizedBox(width: 4),
            _buildFlipDigit(_hour[1]),
            const SizedBox(width: 16),
            Text(
              ':',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                color: themeColor.color.withValues(
                  alpha: 0.9 * opacityMultiplier,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildFlipDigit(_minute[0]),
            const SizedBox(width: 4),
            _buildFlipDigit(_minute[1]),
          ],
        ),
        if (_period.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _period,
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: themeColor.color.withValues(
                alpha: 0.9 * opacityMultiplier,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          _date,
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 3,
            fontWeight: FontWeight.w400,
            color: themeColor.color.withValues(alpha: 0.9 * opacityMultiplier),
          ),
        ),
      ],
    );
  }

  Widget _buildFlipDigit(String digit) {
    return Container(
      width: 54,
      height: 75,
      decoration: BoxDecoration(
        color: themeColor.color.withValues(alpha: 0.2 * opacityMultiplier),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeColor.color.withValues(alpha: 0.5 * opacityMultiplier),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: themeColor.color.withValues(alpha: opacityMultiplier),
          ),
        ),
      ),
    );
  }
}

/// Elegant Clock Widget - Refined and sophisticated
class ElegantClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const ElegantClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  String get _time => timeFormat == TimeFormat.hour12
      ? DateFormat('h:mm').format(time)
      : DateFormat('HH:mm').format(time);
  String get _period =>
      timeFormat == TimeFormat.hour12 ? DateFormat('a').format(time) : '';
  String get _dayOfWeek => DateFormat('EEEE').format(time);
  String get _date => DateFormat('MMMM d, y').format(time);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _dayOfWeek,
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.5 * opacityMultiplier),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _time,
              style: TextStyle(
                fontSize: 68,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
                color: themeColor.color.withValues(alpha: opacityMultiplier),
                fontFeatures: const [FontFeature.proportionalFigures()],
              ),
            ),
            if (_period.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 8),
                child: Text(
                  _period,
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w300,
                    color: themeColor.color.withValues(
                      alpha: 0.6 * opacityMultiplier,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          width: 120,
          color: themeColor.color.withValues(alpha: 0.3 * opacityMultiplier),
        ),
        const SizedBox(height: 8),
        Text(
          _date,
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.5 * opacityMultiplier),
          ),
        ),
      ],
    );
  }
}

/// Binary Clock Widget - Geek mode - binary time
class BinaryClockWidget extends StatelessWidget {
  final DateTime time;
  final AppThemeColor themeColor;
  final TimeFormat timeFormat;
  final double opacityMultiplier;

  const BinaryClockWidget({
    super.key,
    required this.time,
    required this.themeColor,
    required this.timeFormat,
    this.opacityMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BINARY TIME',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.4 * opacityMultiplier),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBinaryColumn('H', time.hour ~/ 10, 2),
            const SizedBox(width: 8),
            _buildBinaryColumn('', time.hour % 10, 4),
            const SizedBox(width: 20),
            _buildBinaryColumn('M', time.minute ~/ 10, 3),
            const SizedBox(width: 8),
            _buildBinaryColumn('', time.minute % 10, 4),
            const SizedBox(width: 20),
            _buildBinaryColumn('S', time.second ~/ 10, 3),
            const SizedBox(width: 8),
            _buildBinaryColumn('', time.second % 10, 4),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          timeFormat == TimeFormat.hour12
              ? DateFormat('h:mm:ss a').format(time)
              : DateFormat('HH:mm:ss').format(time),
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.5 * opacityMultiplier),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEE, MMM d').format(time),
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
            color: themeColor.color.withValues(alpha: 0.4 * opacityMultiplier),
          ),
        ),
      ],
    );
  }

  Widget _buildBinaryColumn(String label, int value, int bits) {
    return Column(
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w400,
                color: themeColor.color.withValues(
                  alpha: 0.5 * opacityMultiplier,
                ),
              ),
            ),
          ),
        ...List.generate(bits, (index) {
          final bitIndex = bits - 1 - index;
          final isOn = (value & (1 << bitIndex)) != 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isOn
                    ? themeColor.color.withValues(alpha: opacityMultiplier)
                    : themeColor.color.withValues(
                        alpha: 0.1 * opacityMultiplier,
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeColor.color.withValues(
                    alpha: 0.3 * opacityMultiplier,
                  ),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
