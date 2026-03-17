import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sleep_timer_event.dart';
part 'sleep_timer_state.dart';

class SleepTimerBloc extends Bloc<SleepTimerEvent, SleepTimerState> {
  Timer? _timer;
  Duration? _totalDuration;
  Duration? _remainingTime;

  SleepTimerBloc() : super(SleepTimerInitial()) {
    on<StartTimerEvent>(_onStartTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);
    on<TimerCompletedEvent>(_onTimerCompleted);
    on<ResetTimerEvent>(_onResetTimer);
  }

  void _onStartTimer(StartTimerEvent event, Emitter<SleepTimerState> emit) {
    _stopExistingTimer();

    _totalDuration = event.duration;
    _remainingTime = event.duration;

    emit(TimerRunningState(
      remainingTime: _remainingTime!,
      totalDuration: _totalDuration!,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime!.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
        add(TimerTickEvent(remainingTime: _remainingTime!));
      } else {
        add(TimerCompletedEvent());
      }
    });
  }

  void _onStopTimer(StopTimerEvent event, Emitter<SleepTimerState> emit) {
    _stopExistingTimer();
    emit(TimerStoppedState());
  }

  void _onTimerTick(TimerTickEvent event, Emitter<SleepTimerState> emit) {
    if (_totalDuration != null) {
      emit(TimerRunningState(
        remainingTime: event.remainingTime,
        totalDuration: _totalDuration!,
      ));
    }
  }

  void _onTimerCompleted(
      TimerCompletedEvent event, Emitter<SleepTimerState> emit) {
    _stopExistingTimer();
    emit(TimerCompletedState());
  }

  void _onResetTimer(ResetTimerEvent event, Emitter<SleepTimerState> emit) {
    _stopExistingTimer();
    emit(SleepTimerInitial());
  }

  void _stopExistingTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isTimerRunning => state is TimerRunningState;

  Duration? get remainingTime => _remainingTime;

  @override
  Future<void> close() {
    _stopExistingTimer();
    return super.close();
  }
}
