import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clock_style_provider.dart';

/// Clock Style Picker Screen
class ClockStylePickerScreen extends ConsumerWidget {
  const ClockStylePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(clockStyleProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Clock style list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: ClockStyle.values.length,
                itemBuilder: (context, index) {
                  final style = ClockStyle.values[index];
                  final isSelected = style == currentStyle;

                  return _buildClockStyleOption(
                    context,
                    ref,
                    style,
                    isSelected,
                  );
                },
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
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'CLOCK STYLE',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockStyleOption(
    BuildContext context,
    WidgetRef ref,
    ClockStyle style,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(clockStyleProvider.notifier).setClockStyle(style);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              _getIconForStyle(style),
              color: Colors.white.withValues(alpha: 0.6),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Style name
                  Text(
                    style.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      letterSpacing: 0.5,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    style.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStyle(ClockStyle style) {
    switch (style) {
      case ClockStyle.digital:
        return Icons.schedule;
      case ClockStyle.analog:
        return Icons.access_time;
      case ClockStyle.minimalist:
        return Icons.timelapse;
      case ClockStyle.bold:
        return Icons.timer;
      case ClockStyle.compact:
        return Icons.schedule_outlined;
      case ClockStyle.modern:
        return Icons.watch_later_outlined;
      case ClockStyle.retro:
        return Icons.flip;
      case ClockStyle.elegant:
        return Icons.access_time_filled;
      case ClockStyle.binary:
        return Icons.code;
    }
  }
}
