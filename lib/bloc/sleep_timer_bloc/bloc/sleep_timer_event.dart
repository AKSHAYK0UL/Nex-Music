part of 'sleep_timer_bloc.dart';

sealed class SleepTimerEvent {}

final class StartTimerEvent extends SleepTimerEvent {
  final Duration duration;

  StartTimerEvent({required this.duration});
}

final class StopTimerEvent extends SleepTimerEvent {}

final class TimerTickEvent extends SleepTimerEvent {
  final Duration remainingTime;

  TimerTickEvent({required this.remainingTime});
}

final class TimerCompletedEvent extends SleepTimerEvent {}

final class ResetTimerEvent extends SleepTimerEvent {}
