import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';

class SleepTimerInfo {
  final bool isActive;
  final Duration? remainingTime;
  final Duration? totalDuration;
  final double progress;

  const SleepTimerInfo({
    required this.isActive,
    this.remainingTime,
    this.totalDuration,
    this.progress = 0.0,
  });

  factory SleepTimerInfo.fromState(dynamic state) {
    if (state is TimerRunningState) {
      return SleepTimerInfo(
        isActive: true,
        remainingTime: state.remainingTime,
        totalDuration: state.totalDuration,
        progress: state.progress,
      );
    }
    return const SleepTimerInfo(isActive: false);
  }

  String get formattedRemainingTime {
    if (remainingTime == null) return '';

    final hours = remainingTime!.inHours;
    final minutes = remainingTime!.inMinutes.remainder(60);
    final seconds = remainingTime!.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
