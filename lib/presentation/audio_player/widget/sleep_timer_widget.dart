import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';
import 'package:nex_music/model/sleep_timer_model.dart';

class SleepTimerWidget extends StatefulWidget {
  const SleepTimerWidget({super.key});

  @override
  State<SleepTimerWidget> createState() => _SleepTimerWidgetState();
}

class _SleepTimerWidgetState extends State<SleepTimerWidget> {
  int selectedMinutes = 15;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SleepTimerBloc, SleepTimerState>(
      builder: (context, state) {
        final timerInfo = SleepTimerInfo.fromState(state);

        if (timerInfo.isActive) {
          return _buildActiveTimer(context, timerInfo);
        } else {
          return _buildTimePicker(context);
        }
      },
    );
  }

  Widget _buildActiveTimer(BuildContext context, SleepTimerInfo timerInfo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 300,
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7).withValues(alpha: 0.75),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 50,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, 'Sleep Timer Active'),
              // const SizedBox(height: 20),
              // Circular progress indicator with timer icon
              SizedBox(
                width: 120,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: timerInfo.progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    const Icon(
                      CupertinoIcons.timer,
                      size: 40,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                timerInfo.formattedRemainingTime,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Music will stop when timer ends',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      context.read<SleepTimerBloc>().add(StopTimerEvent());
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    child: const Text(
                      'Stop Timer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7).withValues(alpha: 0.75),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 50,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context, 'Set Sleep Timer'),
              const SizedBox(height: 10),
              const Text(
                'Select minutes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Time picker
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedMinutes - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMinutes = index + 1;
                    });
                  },
                  children: List.generate(
                    180, // 1 to 120 minutes
                    (index) => Center(
                      child: Text(
                        '${index + 1} ${index + 1 == 1 ? 'minute' : 'minutes'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        final duration = Duration(minutes: selectedMinutes);
                        context.read<SleepTimerBloc>().add(
                              StartTimerEvent(duration: duration),
                            );
                        Navigator.pop(context);
                      },
                      // color: Colors.blue,
                      // borderRadius: BorderRadius.circular(25),
                      child: const Text(
                        'Set Timer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
