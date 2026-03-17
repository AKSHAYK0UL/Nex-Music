part of 'sleep_timer_bloc.dart';

sealed class SleepTimerState {}

class SleepTimerInitial extends SleepTimerState {}

class TimerRunningState extends SleepTimerState {
  final Duration remainingTime;
  final Duration totalDuration;

  TimerRunningState({
    required this.remainingTime,
    required this.totalDuration,
  });

  double get progress =>
      1.0 - (remainingTime.inSeconds / totalDuration.inSeconds);
}

class TimerStoppedState extends SleepTimerState {}

class TimerCompletedState extends SleepTimerState {}
