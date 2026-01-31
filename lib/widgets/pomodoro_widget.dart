import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/theme_provider.dart';

/// Pomodoro Timer Widget - Simple work timer
/// Timer state is managed globally via PomodoroProvider so it keeps running
/// even when navigating to different screens.
class PomodoroWidget extends ConsumerWidget {
  final VoidCallback? onExpand;

  const PomodoroWidget({super.key, this.onExpand});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    final pomodoroState = ref.watch(pomodoroProvider);
    final pomodoroNotifier = ref.read(pomodoroProvider.notifier);

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
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'POMODORO',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                      color: themeColor.color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Text(
                pomodoroState.isWorkSession ? 'WORK' : 'BREAK',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                  color: pomodoroState.isWorkSession
                      ? Colors.red.withValues(alpha: 0.7)
                      : Colors.green.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Timer Display
          Center(
            child: Column(
              children: [
                // Time
                Text(
                  _formatTime(pomodoroState.remainingSeconds),
                  style: TextStyle(
                    fontSize: 56,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w200,
                    color: themeColor.color.withValues(alpha: 0.9),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset button
              _buildControlButton(
                icon: Icons.refresh,
                onTap: pomodoroNotifier.resetTimer,
                color: Colors.white.withValues(alpha: 0.3),
              ),

              const SizedBox(width: 16),

              // Play/Pause button
              _buildControlButton(
                icon: pomodoroState.isRunning ? Icons.pause : Icons.play_arrow,
                onTap: pomodoroState.isRunning
                    ? pomodoroNotifier.pauseTimer
                    : pomodoroNotifier.startTimer,
                color: pomodoroState.isWorkSession
                    ? Colors.red.withValues(alpha: 0.5)
                    : Colors.green.withValues(alpha: 0.5),
                size: 56,
              ),

              const SizedBox(width: 16),

              // Skip button
              _buildControlButton(
                icon: Icons.skip_next,
                onTap: pomodoroNotifier.skipToNext,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: size * 0.5,
        ),
      ),
    );
  }
}
