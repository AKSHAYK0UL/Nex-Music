import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';

class SleepTimerService {
  static SleepTimerService? _instance;
  static SleepTimerService get instance => _instance ??= SleepTimerService._();

  SleepTimerService._();

  StreamSubscription<SleepTimerState>? _timerSubscription;
  SongstreamBloc? _songstreamBloc;
  BuildContext? _context;

  void initialize(SleepTimerBloc sleepTimerBloc, SongstreamBloc songstreamBloc,
      BuildContext context) {
    _songstreamBloc = songstreamBloc;
    _context = context;

    // Cancel existing subscription if any
    _timerSubscription?.cancel();

    // Listen to sleep timer state changes
    _timerSubscription = sleepTimerBloc.stream.listen((state) {
      if (state is TimerCompletedState) {
        _pauseMusic();
        _showCompletionDialog();
      }
    });
  }

  void _pauseMusic() {
    if (_songstreamBloc != null) {
      _songstreamBloc!.add(PauseEvent());
    }
  }

  void _showCompletionDialog() {
    if (_context != null && _context!.mounted) {
      showCupertinoDialog(
        context: _context!,
        barrierDismissible: false, 
        builder: (context) => CupertinoAlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.timer,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Timer Completed'),
            ],
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Sleep timer has finished and music has been stopped.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void dispose() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
    _songstreamBloc = null;
    _context = null;
  }
}
