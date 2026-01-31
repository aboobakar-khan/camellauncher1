import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pomodoro timer state
class PomodoroState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isWorkSession;
  final int workDuration; // in minutes
  final int breakDuration; // in minutes

  const PomodoroState({
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.isWorkSession = true,
    this.workDuration = 25,
    this.breakDuration = 10,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isWorkSession,
    int? workDuration,
    int? breakDuration,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isWorkSession: isWorkSession ?? this.isWorkSession,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
    );
  }
}

/// Pomodoro timer notifier - manages timer state globally
class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier() : super(const PomodoroState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      remainingSeconds: state.workDuration * 60,
      isWorkSession: true,
    );
  }

  void skipToNext() {
    _onTimerComplete();
  }

  void _onTimerComplete() {
    _timer?.cancel();

    if (state.isWorkSession) {
      // Work complete, start break
      state = state.copyWith(
        isRunning: false,
        remainingSeconds: state.breakDuration * 60,
        isWorkSession: false,
      );
    } else {
      // Break complete, start work
      state = state.copyWith(
        isRunning: false,
        remainingSeconds: state.workDuration * 60,
        isWorkSession: true,
      );
    }
  }

  void setWorkDuration(int minutes) {
    state = state.copyWith(workDuration: minutes);
    if (state.isWorkSession && !state.isRunning) {
      state = state.copyWith(remainingSeconds: minutes * 60);
    }
  }

  void setBreakDuration(int minutes) {
    state = state.copyWith(breakDuration: minutes);
    if (!state.isWorkSession && !state.isRunning) {
      state = state.copyWith(remainingSeconds: minutes * 60);
    }
  }
}

/// Global pomodoro provider - keeps timer running across screen changes
final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);
